if ENV['AC'] then
  require_relative '../application_centric/app/controllers/imports_controller'
else
  require_relative '../framework_centric/app/controllers/imports_controller'
end

describe ImportsController do
  subject(:controller) { described_class.new(params) }

  let(:params) { { url: url } }
  let(:url) { 'some.url' }

  describe '#create' do
    subject(:create) { controller.create }

    before do
      allow(controller).to receive(:render)
    end

    context 'when the url is unsupported' do
      let(:url) { 'unsupported' }

      before { create }

      it 'renders the new import page with a message' do
        expect(controller).to have_received(:render)
          .with(:new, notice: a_kind_of(String))
      end
    end

    context 'when the url is the National Weather Service RSS feed' do
      let(:url) { 'nws.xml' }
      let(:feed_items) { [] }

      before do
        allow(RSS).to receive(:read).and_return(feed_items)
      end

      it 'reads the feed' do
        create

        expect(RSS).to have_received(:read).with(url)
      end

      context 'and there are NO items in the feed' do
        let(:feed_items) { [] }

        before { create }

        it 'renders the new import page with a message' do
          expect(controller).to have_received(:render)
            .with(:new, notice: a_kind_of(String))
        end
      end

      context 'and there are items in the feed' do
        let(:feed_items) { [feed_item1, feed_item2] }
        let(:feed_item1) do
          instance_double(
            'feed_item',
            id: 'id1',
            title: 'title1',
            summary: 'summary1',
            published: 'published1',
            updated: 'updated1',
            cap_effective: 'cap_effective1',
            cap_expires: 'cap_expires1'
          )
        end
        let(:feed_item2) do
          instance_double(
            'feed_item',
            id: 'id2',
            title: 'title2',
            summary: 'summary2',
            published: 'published2',
            updated: 'updated2',
            cap_effective: 'cap_effective2',
            cap_expires: 'cap_expires2'
          )
        end
        let(:alert1) { instance_double(Alert, active?: false) }
        let(:alert2) { instance_double(Alert, active?: false) }

        before do
          allow(Alert).to receive(:create).and_return(alert1, alert2)
          allow(controller).to receive(:redirect_to)

          create
        end

        it 'creates an alert for each item in the feed' do
          expect(Alert).to have_received(:create).with(
            {
              id: feed_item1.id,
              title: feed_item1.title,
              description: feed_item1.summary,
              published_at: feed_item1.published,
              updated_at: feed_item1.updated,
              effective_at: feed_item1.cap_effective,
              expires_at: feed_item1.cap_expires
            }
          )
          expect(Alert).to have_received(:create).with(
            {
              id: feed_item2.id,
              title: feed_item2.title,
              description: feed_item2.summary,
              published_at: feed_item2.published,
              updated_at: feed_item2.updated,
              effective_at: feed_item2.cap_effective,
              expires_at: feed_item2.cap_expires
            }
          )
        end

        it 'redirects to the alerts page with a message' do
          expect(controller).to have_received(:redirect_to)
            .with('/alerts', notice: a_kind_of(String))
        end
      end
    end

    context 'when the url is the National Oceanic and Atmospheric Administration RSS feed' do
      let(:url) { 'noaa.xml' }
      let(:feed_items) { [] }

      before do
        allow(RSS).to receive(:read).and_return(feed_items)
      end

      it 'reads the feed' do
        create

        expect(RSS).to have_received(:read).with(url)
      end

      context 'and there are NO items in the feed' do
        let(:feed_items) { [] }

        before { create }

        it 'renders the new import page with a message' do
          expect(controller).to have_received(:render)
            .with(:new, notice: a_kind_of(String))
        end
      end

      context 'and there are items in the feed' do
        let(:feed_items) { [feed_item1, feed_item2] }
        let(:feed_item1) do
          instance_double(
            'feed_item',
            id: 'id1',
            title: 'title1',
            description: 'description1',
            pub_date: '2020-01-01 00:00:00 -0800',
            last_update: 'last_update1',
          )
        end
        let(:feed_item2) do
          instance_double(
            'feed_item',
            id: 'id2',
            title: 'title2',
            description: 'description2',
            pub_date: '2020-02-02 00:00:00 -0800',
            last_update: 'last_update2',
          )
        end
        let(:alert) { instance_double(Alert, active?: false) }

        before do
          allow(Alert).to receive(:create).and_return(alert)
          allow(controller).to receive(:redirect_to)

          create
        end

        it 'creates an alert for each item in the feed' do
          expect(Alert).to have_received(:create).with(
            {
              id: feed_item1.id,
              title: feed_item1.title,
              description: feed_item1.description,
              published_at: feed_item1.pub_date,
              updated_at: feed_item1.last_update,
              effective_at: feed_item1.pub_date,
              expires_at: '2020-01-01 06:00:00 -0800'
            }
          )
          expect(Alert).to have_received(:create).with(
            {
              id: feed_item2.id,
              title: feed_item2.title,
              description: feed_item2.description,
              published_at: feed_item2.pub_date,
              updated_at: feed_item2.last_update,
              effective_at: feed_item2.pub_date,
              expires_at: '2020-02-02 06:00:00 -0800'
            }
          )
        end

        it 'redirects to the alerts page with a message' do
          expect(controller).to have_received(:redirect_to)
            .with('/alerts', notice: a_kind_of(String))
        end
      end
    end

    context 'when the url is the Tornado Weather Alerts Twitter feed' do
      let(:url) { 'twitter.com/TornadoWeather' }
      let(:feed_items) { [] }

      before do
        allow(Twitter).to receive(:get_tweets).and_return(feed_items)
      end

      it 'reads the feed' do
        create

        expect(Twitter).to have_received(:get_tweets).with(url)
      end

      context 'and there are NO items in the feed' do
        let(:feed_items) { [] }

        before { create }

        it 'renders the new import page with a message' do
          expect(controller).to have_received(:render)
            .with(:new, notice: a_kind_of(String))
        end
      end

      context 'and there are items in the feed' do
        let(:feed_items) { [feed_item1, feed_item2] }
        let(:feed_item1) do
          instance_double(
            'feed_item',
            id: 'id1',
            body: 'title1.description1',
            date_time: '2020-01-01 00:00:00 -0800'
          )
        end
        let(:feed_item2) do
          instance_double(
            'feed_item',
            id: 'id2',
            body: 'title2.description2',
            date_time: '2020-02-02 00:00:00 -0800'
          )
        end
        let(:alert) { instance_double(Alert, active?: false) }

        before do
          allow(Alert).to receive(:create).and_return(alert)
          allow(controller).to receive(:redirect_to)

          create
        end

        it 'creates an alert for each item in the feed' do
          expect(Alert).to have_received(:create).with(
            {
              id: feed_item1.id,
              title: 'title1',
              description: 'description1',
              published_at: feed_item1.date_time,
              updated_at: feed_item1.date_time,
              effective_at: feed_item1.date_time,
              expires_at: '2020-01-01 01:00:00 -0800'
            }
          )
          expect(Alert).to have_received(:create).with(
            {
              id: feed_item2.id,
              title: 'title2',
              description: 'description2',
              published_at: feed_item2.date_time,
              updated_at: feed_item2.date_time,
              effective_at: feed_item2.date_time,
              expires_at: '2020-02-02 01:00:00 -0800'
            }
          )
        end

        it 'redirects to the alerts page with a message' do
          expect(controller).to have_received(:redirect_to)
            .with('/alerts', notice: a_kind_of(String))
        end
      end
    end

    context 'when there are active alerts' do
      let(:url) { 'nws.xml' }
      let(:feed_items) { [feed_item1, feed_item2] }
      let(:feed_item1) do
        instance_double(
          'feed_item',
          id: 'id1',
          title: 'title1',
          summary: 'summary1',
          published: 'published1',
          updated: 'updated1',
          cap_effective: 'cap_effective1',
          cap_expires: 'cap_expires1'
        )
      end
      let(:feed_item2) do
        instance_double(
          'feed_item',
          id: 'id2',
          title: 'title2',
          summary: 'summary2',
          published: 'published2',
          updated: 'updated2',
          cap_effective: 'cap_effective2',
          cap_expires: 'cap_expires2'
        )
      end
      let(:alert1) { instance_double(Alert, active?: true) }
      let(:alert2) { instance_double(Alert, active?: false) }
      let(:subscribers) { [] }
      let(:sms) { instance_double(SMS, text: true) }

      before do
        allow(RSS).to receive(:read).and_return(feed_items)
        allow(Alert).to receive(:create).and_return(alert1, alert2)
        allow(Subscriber).to receive(:all).and_return(subscribers)
        allow(SMS).to receive(:new).and_return(sms)
        allow(EmailClient).to receive(:post)
        allow(Messenger).to receive(:deliver)

        create
      end

      context 'and there are NO subscribers' do
        let(:subscribers) { [] }

        it 'does not notify anyone' do
          expect(sms).not_to have_received(:text)
        end
      end

      context 'and there are SMS subscribers' do
        let(:subscribers) { [subscriber1, subscriber2] }
        let(:subscriber1) { instance_double(Subscriber, channel: 'SMS', address: '123') }
        let(:subscriber2) { instance_double(Subscriber, channel: 'unknown', address: 'qwe') }

        it 'notifies each subsriber of the active alerts' do
          expect(sms).to have_received(:text)
            .with(from: '+14152345678', to: '123', body: 'There are 1 new active alerts.')
          expect(sms).not_to have_received(:text)
            .with(from: '+14152345678', to: 'qwe', body: 'There are 1 new active alerts.')
        end
      end

      context 'and there are Email subscribers' do
        let(:subscribers) { [subscriber1, subscriber2] }
        let(:subscriber1) { instance_double(Subscriber, channel: 'Email', address: 'email@example.com') }
        let(:subscriber2) { instance_double(Subscriber, channel: 'unknown', address: 'qwe') }

        it 'notifies each subsriber of the active alerts' do
          expect(EmailClient).to have_received(:post).with(
            from: 'weather@alerts.com',
            to: [{ email: 'email@example.com' }],
            subject: 'Alert',
            content: [{
              value: 'There are 1 new active alerts.',
              type: 'text/plain'
            }]
          )
          expect(EmailClient).not_to have_received(:post)
            .with(a_hash_including(to: [{ email: 'qwe' }]))
        end
      end

      context 'and there are Messenger subscribers' do
        let(:subscribers) { [subscriber1, subscriber2] }
        let(:subscriber1) { instance_double(Subscriber, channel: 'Messenger', address: 'messenger_user') }
        let(:subscriber2) { instance_double(Subscriber, channel: 'unknown', address: 'qwe') }

        it 'notifies each subsriber of the active alerts' do
          expect(Messenger).to have_received(:deliver).with(
            recipient: { id: 'messenger_user' },
            message: { text: 'There are 1 new active alerts.' },
            message_type: Messenger::UPDATE
          )
          expect(Messenger).not_to have_received(:deliver)
            .with(a_hash_including(recipient: { id: 'qwe' }))
        end
      end
    end
  end
end

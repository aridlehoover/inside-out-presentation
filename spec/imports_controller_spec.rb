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

        before do
          allow(Alert).to receive(:create)
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

        before do
          allow(Alert).to receive(:create)
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
  end
end

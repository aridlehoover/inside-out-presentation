require_relative '../../../lib/base_controller'
require_relative '../../../lib/rss'
require_relative '../../../lib/twitter'
require_relative '../../../lib/alert'
require_relative '../../../lib/subscriber'
require_relative '../../../lib/sms'
require_relative '../../../lib/email_client'

class ImportsController < BaseController
  def create
    feed_items = case params[:url]
    when /xml/
      RSS.read(params[:url])
    when /twitter/
      Twitter.get_tweets(params[:url])
    else
      return render :new, notice: 'Unable to import alerts.'
    end

    if feed_items.empty?
      return render :new, notice: 'Unable to import alerts.'
    end

    alerts = feed_items.map do |item|
      case params[:url]
      when 'nws.xml'
        Alert.create(
          id: item.id,
          title: item.title,
          description: item.summary,
          published_at: item.published,
          updated_at: item.updated,
          effective_at: item.cap_effective,
          expires_at: item.cap_expires
        )
      when 'noaa.xml'
        Alert.create(
          id: item.id,
          title: item.title,
          description: item.description,
          published_at: item.pub_date,
          updated_at: item.last_update,
          effective_at: item.pub_date,
          expires_at: (Time.parse(item.pub_date) + 6 * 3600).to_s
        )
      when 'twitter.com/TornadoWeather'
        title, desc = item.body.match(/^([^.]*)\.(.*)/).captures
        Alert.create(
          id: item.id,
          title: title,
          description: desc,
          published_at: item.date_time,
          updated_at: item.date_time,
          effective_at: item.date_time,
          expires_at: (Time.parse(item.date_time) + 3600).to_s
        )
      end
    end

    active_alerts = alerts.select(&:active?)

    if active_alerts.any?
      message = "There are #{active_alerts.count} new active alerts."

      Subscriber.all.each do |subscriber|
        case subscriber.channel
        when 'SMS'
          client = SMS.new(ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN'])
          client.text(
            from: '+14152345678',
            to: subscriber.address,
            body: message
          )
        when 'Email'
          EmailClient.post(
            from: 'weather@alerts.com',
            to: [{ email: subscriber.address }],
            subject: 'Alert',
            content: [{ value: message, type: 'text/plain' }]
          )
        end
      end
    end

    redirect_to '/alerts', notice: 'Alerts imported.'
  end
end

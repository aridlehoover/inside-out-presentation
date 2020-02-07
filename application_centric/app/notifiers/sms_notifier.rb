require_relative '../../../lib/sms'

class SMSNotifier < Notifier
  attr_reader :subscriber, :alerts, :client

  def initialize(subscriber, alerts, client = default_client)
    @subscriber = subscriber
    @alerts = alerts
    @client = client
  end

  def notify
    client.text(
      from: '+14152345678',
      to: subscriber.address,
      body: message
    )
  end

  private

  def default_client
    SMS.new(ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN'])
  end
end

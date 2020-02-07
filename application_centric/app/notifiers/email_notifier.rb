require_relative '../../../lib/email_client'

class EmailNotifier < Notifier
  attr_reader :subscriber, :alerts, :client

  def initialize(subscriber, alerts, client = EmailClient)
    @subscriber = subscriber
    @alerts = alerts
    @client = client
  end

  def notify
    client.post(
      from: 'weather@alerts.com',
      to: [{ email: subscriber.address }],
      subject: 'Alert',
      content: [{ value: message, type: 'text/plain' }]
    )
  end
end

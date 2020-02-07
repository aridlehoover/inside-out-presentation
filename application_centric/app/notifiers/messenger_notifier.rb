require_relative '../../../lib/messenger'

class MessengerNotifier < Notifier
  attr_reader :subscriber, :alerts, :client

  def initialize(subscriber, alerts, client = Messenger)
    @subscriber = subscriber
    @alerts = alerts
    @client = client
  end

  def notify
    client.deliver(
      {
        recipient: { id: subscriber.address },
        message: { text: message },
        message_type: client::UPDATE
      }
    )
  end
end

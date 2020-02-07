require_relative './notifier'
require_relative './sms_notifier'

class NotifierFactory
  def self.build(subscriber, alerts)
    case subscriber.channel
    when 'SMS'
      SMSNotifier.new(subscriber, alerts)
    else
      Notifier.new(subscriber, alerts)
    end
  end
end
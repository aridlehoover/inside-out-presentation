require_relative './notifier'
require_relative './sms_notifier'
require_relative './email_notifier'

class NotifierFactory
  def self.build(subscriber, alerts)
    case subscriber.channel
    when 'SMS'
      SMSNotifier.new(subscriber, alerts)
    when 'Email'
      EmailNotifier.new(subscriber, alerts)
    else
      Notifier.new(subscriber, alerts)
    end
  end
end
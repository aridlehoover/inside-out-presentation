class Notifier
  attr_reader :subscriber, :alerts

  def initialize(subscriber, alerts)
    @subscriber = subscriber
    @alerts = alerts
  end

  def notify; end
end
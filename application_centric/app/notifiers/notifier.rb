class Notifier
  attr_reader :subscriber, :alerts

  def initialize(subscriber, alerts)
    @subscriber = subscriber
    @alerts = alerts
  end

  def notify; end

  private

  def message
    "There are #{alerts.count} new active alerts."
  end
end
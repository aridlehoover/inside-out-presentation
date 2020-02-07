require_relative '../../../lib/subscriber'
require_relative '../../domain/repositories/subscriber_repository'
require_relative '../notifiers/notifier_factory'

class NotificationAdapter
  attr_reader :repository, :factory

  def initialize(repository = SubscriberRepository.new, factory = NotifierFactory)
    @repository = repository
    @factory = factory
  end

  def on_success(alerts)
    active_alerts = alerts.select(&:active?)

    if active_alerts.any?
      repository.find_all.each do |subscriber|
        factory.build(subscriber, active_alerts).notify
      end
    end
  end

  def on_failure; end
end

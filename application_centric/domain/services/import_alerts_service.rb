class ImportAlertsService
  attr_reader :reader, :repository, :observers

  def initialize(reader, repository, observers)
    @reader = reader
    @repository = repository
    @observers = Array(observers)
  end

  def perform
    return observers.each(&:on_failure) if feed_items.empty?

    observers.each { |observer| observer.on_success(alerts) }
  end

  private

  def feed_items
    @feed_items ||= reader.read
  end

  def alerts
    @alerts ||= feed_items.map { |feed_item| repository.create(feed_item) }
  end
end

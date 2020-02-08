require_relative '../../../lib/base_worker'
require_relative '../../domain/services/import_alerts_service'
require_relative '../../domain/repositories/alert_repository'
require_relative '../readers/reader_factory'
require_relative '../adapters/notification_adapter'
require_relative '../adapters/imports_queue_adapter'

class ImportsWorker < BaseWorker
  def perform
    ImportAlertsService.new(reader, repository, observers).perform
  end

  private

  def reader
    ReaderFactory.build(params[:url])
  end

  def repository
    AlertRepository.new
  end

  def observers
    [
      NotificationAdapter.new,
      ImportsQueueAdapter.new(params[:message_id])
    ]
  end
end

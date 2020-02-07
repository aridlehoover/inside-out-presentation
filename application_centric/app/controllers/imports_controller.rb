require_relative '../../../lib/base_controller'
require_relative '../../domain/services/import_alerts_service'
require_relative '../../domain/repositories/alert_repository'
require_relative '../readers/reader_factory'
require_relative '../adapters/import_alerts_response_adapter'

class ImportsController < BaseController
  def create
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
      ImportAlertsResponseAdapter.new(self)
    ]
  end
end

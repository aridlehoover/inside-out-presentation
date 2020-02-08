require_relative '../../../lib/imports_queue'

class ImportsQueueAdapter
  attr_reader :message_id, :queue

  def initialize(message_id, queue = ImportsQueue)
    @message_id = message_id
    @queue = queue
  end

  def on_success(alerts)
    queue.delete(message_id)
  end

  def on_failure
    queue.delete(message_id)
  end
end
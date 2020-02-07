require_relative '../../../lib/subscriber'

class SubscriberRepository
  def find_all
    Subscriber.all
  end
end

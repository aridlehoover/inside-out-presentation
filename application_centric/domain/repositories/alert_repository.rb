require_relative '../../../lib/alert'

class AlertRepository
  def create(attributes)
    Alert.create(attributes)
  end
end
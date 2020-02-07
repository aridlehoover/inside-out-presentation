class BaseController
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def render(*args); end
  def redirect_to(*args); end
end
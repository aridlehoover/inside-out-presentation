class Reader
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def read
    []
  end
end

require_relative './reader'
require_relative './nws_reader'

class ReaderFactory
  def self.build(url)
    case url
    when /nws\.xml/
      NWSReader.new(url)
    else
      Reader.new(url)
    end
  end
end
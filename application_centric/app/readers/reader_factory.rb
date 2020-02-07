require_relative './reader'
require_relative './nws_reader'
require_relative './noaa_reader'
require_relative './twa_reader'

class ReaderFactory
  def self.build(url)
    case url
    when /nws\.xml/
      NWSReader.new(url)
    when /noaa\.xml/
      NOAAReader.new(url)
    when /twitter.com\/TornadoWeather/
      TWAReader.new(url)
    else
      Reader.new(url)
    end
  end
end

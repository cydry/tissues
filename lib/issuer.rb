require 'net/http'

class MyServer
  def request(*prams)
    nil
  end
end

class Issuer < MyServer
  def initialize
    @@uri = URI.parse(build_uri())
  end

  def request(*params)
    if @@uri.is_a? URI::Generic
      begin
        Net::HTTP.get(@@uri)
      rescue => e
        puts "Issuer(#{self.class}), #{e.message}"
      end
    end
  end

  # Have to be overriden.
  # Return URI by string.
  def build_uri
    String.new
  end
end

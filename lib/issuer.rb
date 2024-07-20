require 'net/http'

class MyServer
  def request(params)
    nil
  end
end

class Issuer < MyServer
  def initialize
    @@uri = URI.parse(build_uri())
  end

  def request(params)
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

class GitHubIssuer < Issuer
  ISSUES_API =
    "https://api.github.com/repos/:USER/:PROJECT/issues"

  def initialize(user, project)
    @uri = ISSUES_API
             .gsub(/:USER/, user)
             .gsub(/:PROJECT/, project)
    super()
  end

  def build_uri
    @uri
  end
end

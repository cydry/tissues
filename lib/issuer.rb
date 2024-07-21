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
        process(params)
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
  def process(params)
    nil
  end
end

class GitHubIssuer < Issuer
  ISSUES_API =
    "https://api.github.com/repos/:USER/:PROJECT/issues"

  def initialize(user, project, number=nil)
    @uri = ISSUES_API
             .gsub(/:USER/, user)
             .gsub(/:PROJECT/, project)

    @uri += "/#{number}/comments" unless number.nil?
    super()
  end

  def build_uri
    @uri
  end

  def process(params)
    if params[0] == :get
      Net::HTTP.get(@@uri)
    elsif params[0] == :post
      params.shift()
      post params
    end
  end

  def post(params)
    data = params.shift
    cred = params.shift

    req = Net::HTTP::Post.new(@@uri.path)
    req["Accept"] = "application/vnd.github+json"
    req["Authorization"] = "Bearer #{cred}"
    req["X-GitHub-Api-Version"] = "2022-11-28"
    req.body = data

    http = Net::HTTP.new(@@uri.host, @@uri.port)
    http.use_ssl = true
    http.start {|http| http.request(req)}
  end
end

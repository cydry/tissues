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

  def initialize(user, project, number=nil, state=nil)
    @uri = ISSUES_API
             .gsub(/:USER/, user)
             .gsub(/:PROJECT/, project)
    unless number.nil?
      @uri += "/#{number}"
      if state.nil?
        # when state is NOT set with "close"
        @uri += "/comments"
      end
    end
    super()
  end

  def build_uri
    @uri
  end

  def process(params)
    if params[0] == :get
      Net::HTTP.get(@@uri)
    elsif params[0] == :post
      process_push params
    elsif params[0] == :patch
      process_push params
    end
  end

  def process_push(params)
    method = params.shift
    data = params.shift
    cred = params.shift

    req = build_http_request(method)
    req["Accept"] = "application/vnd.github+json"
    req["Authorization"] = "Bearer #{cred}"
    req["X-GitHub-Api-Version"] = "2022-11-28"
    req.body = data

    http = Net::HTTP.new(@@uri.host, @@uri.port)
    http.use_ssl = true
    http.start {|http| http.request(req)}
  end

  def build_http_request(method)
    if method == :post
      Net::HTTP::Post.new(@@uri.path)
    elsif method == :patch
      Net::HTTP::Patch.new(@@uri.path)
    else
      puts "GitHubIssuer unexpected method:#{method}"
      exit(false)
    end
  end
end

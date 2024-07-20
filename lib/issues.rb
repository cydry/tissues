require_relative './issuer.rb'
require_relative './formatter.rb'

class MyClient
  def initialize
    @@remote = set_server()
    unless @@remote.respond_to? :request
      exit(false)
    end
  end

  def fetch(*params)
    @@response = @@remote.request(params)
  end

  def get_response
    @@response
  end

  # Have to be overriden.
  # Return MyServer class
  def set_server
    nil
  end
end

class Issues < MyClient
  def set_server
    Issuer.new
  end
end

class GitHubIssues < Issues
  include Formatter::GitHubIssues

  def initialize(user, project)
    @user = user
    @project = project
    super()
  end

  def set_server
    GitHubIssuer.new(@user, @project)
  end

  def to_s
    pretty get_response()
  end
end

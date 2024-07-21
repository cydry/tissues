require_relative './issuer.rb'
require_relative './formatter.rb'

class MyClient
  def initialize
    @@remote = set_server()
    unless @@remote.respond_to? :request
      exit(false)
    end
  end

  def remote_call(params)
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

  # Have to be overriden.
  # Return MyServer class
  def fetch
    nil
  end
  def push
    nil
  end
end

class GitHubIssues < Issues
  include Formatter::GitHubIssues
  attr_accessor :data, :credential

  def initialize(user, project, number=nil)
    @user = user
    @project = project
    @number = number
    super()
  end

  def set_server
    GitHubIssuer.new(@user, @project, @number)
  end

  def to_s
    if issues?
      pretty get_response()
    elsif comments?
      pretty_comments get_response()
    end
  end

  def fetch
    remote_call([:get])
  end

  def push
    remote_call([:post, @data, @credential])
  end

  def issues?
    @number.nil?
  end

  def comments?
    not @number.nil?
  end
end

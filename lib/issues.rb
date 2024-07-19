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

  def set_server
    nil
  end
end


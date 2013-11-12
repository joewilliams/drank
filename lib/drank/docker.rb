module Drank
  class Docker

    def self.get_version()
      path = "/version"
      get_request(path)
    end

    def self.get_containers()
      path = "/containers/json"
      get_request(path)
    end

    def self.get_container(id)
      path = "/containers/#{id}/json"
      get_request(path)
    end

    private

    def self.get_request(path)
      parsed_uri = URI.parse(Drank::Config.uri)

      case parsed_uri.scheme
      when "http"
        data = Excon.get("#{Drank::Config.uri}#{path}")
      when "unix"
        data = Excon.get("unix://#{path}", :socket => parsed_uri.path)
      end

      Drank::Log.debug(data.inspect)
      JSON.parse(data.body)
    end

  end
end
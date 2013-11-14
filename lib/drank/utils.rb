module Drank
  class Utils

    def self.get_container_host_zk_path(path, hostname)
      File.join(path, hostname)
    end

    def self.get_container_zk_path(path, data)
      File.join(path, data["ID"])
    end

    def self.get_container_service(data)
      service_name = "default"

      data["Config"]["Env"].each do |var|
        if var.include?("SERVICE=")
          var[/\S\=(.*)/]
          service_name = $1
        end
      end

      if service_name == "default"
        Drank::Log.info("Could not parse service name from container #{data["ID"]} using 'default'")
      end

      service_name
    end

  end
end
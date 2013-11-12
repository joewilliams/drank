module Drank
  class Utils

    def self.get_container_host_zk_path(path, hostname)
      File.join(path, hostname)
    end

    def self.get_container_zk_path(path, data)
      File.join(path, data["ID"])
    end

    private

    def self.get_container_service(data)
      service_name = nil

      data["Config"]["Env"].each do |var|
        if var.include?("SERVICE=")
          var[/\S\=(.*)/]
          service_name = $1
        end
      end

      if service_name == nil
        raise("Could not parse service name from container #{data["ID"]}")
      else
        service_name
      end
    end

    def self.get_container_serial_number(data)
      serial = nil

      data["Config"]["Env"].each do |var|
        if var.include?("SERIALNUMBER=")
          var[/\S\=(.*)/]
          serial = $1
        end
      end

      if serial == nil
        raise("Could not parse serial number from container #{data["ID"]}")
      else
        serial
      end
    end

  end
end
module Drank
  class Service

    def self.run()
      Drank::Log.info("URI: #{Drank::Config.uri}")
      Drank::Log.info("ZK: #{Drank::Config.zookeeper}")
      Drank::Log.info("Interval: #{Drank::Config.interval}")

      zk_container_host_session = Zookeeper.new(Drank::Config.zookeeper)

      # setup initial zk paths
      zk_init(zk_container_host_session)

      # create ephemeral node for host where drank is currently running
      create_container_host(zk_container_host_session)

      container_sessions = {}

      loop do
        Drank::Log.info("Lurkin' for containers ...")
        # loop through containers on this host creating zk sessions for each session
        containers = Drank::Docker.get_containers()

        current_containers = []

        containers.each do |cntr|
          unless container_sessions[cntr["Id"]]
            Drank::Log.info("Found new container (#{cntr["Id"]})")

            begin
              cntr_sess = Zookeeper.new(Drank::Config.zookeeper)
              create_container(cntr_sess, cntr["Id"]) # sets initial data too
              container_sessions.store(cntr["Id"], cntr_sess) # finally store the session for use later
            rescue Exception => e
              Drank::Log.error("Could not create session for #{cntr["Id"]}")
            end
          end

          current_containers << cntr["Id"]
        end

        # find all the sessions that we don't have containers for, delete 'em
        stale_sessions = container_sessions.keys - current_containers

        if stale_sessions.length > 0
          Drank::Log.info("Found stale sessions #{stale_sessions.inspect}")

          stale_sessions.each do |id|
            Drank::Log.info("Closing session for container #{id}")
            sess = container_sessions[id]
            sess.close
            container_sessions.delete(id)
          end
        end

        Drank::Log.info("Live sessions #{container_sessions.keys}")
        # chill
        sleep(Drank::Config.interval)
      end

    end

    def self.zk_init(session)
      Drank::Log.info("Initializing ZooKeeper ...")

      # create nodes for container hosts and services
      Drank::ZK.create(session, {:path => File.join(Drank::Config.zk_prefix, "container-hosts"), :recursive => true})
      Drank::ZK.create(session, {:path => File.join(Drank::Config.zk_prefix, "services"), :recursive => true})
    end

    def self.create_container_host(session)
      # create container host path
      Drank::ZK.create(session, {
        :path => get_container_host_zk_path(),
        :recursive => true,
        :ephemeral => true,
        :data => get_container_host_data().to_json
      })
    end

    def self.create_container(session, id)
      # create service/container path
      data = Drank::Docker.get_container(id)

      # create service path if needed
      Drank::ZK.create(session, {
        :path => File.join(Drank::Config.zk_prefix, "services", get_container_service(data))
      })

      begin
        path = get_container_zk_path(data)

        Drank::ZK.create(session, {
          :path => path,
          :ephemeral => true,
          :data => data.to_json
        })
      rescue Exception => e
        Drank::Log.error("Could not create ZK node for container #{id}")
        Drank::Log.error(e)
        raise
      end
    end

    def self.get_container_host_zk_path
      hostname = Socket.gethostname
      File.join(Drank::Config.zk_prefix, "container-hosts", hostname)
    end

    def self.get_container_zk_path(data)
      service = get_container_service(data)
      serial = get_container_serial_number(data)

      File.join(Drank::Config.zk_prefix, "services", service, serial)
    end

    def self.get_container_host_data
      Drank::Docker.get_version()
    end

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
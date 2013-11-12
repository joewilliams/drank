module Drank
  class Service

    def self.run()
      @hostname = Socket.gethostbyname(Socket.gethostname).first.gsub(".", "_")
      @service_zk_path =File.join(Drank::Config.zk_prefix, "services")
      @container_host_zk_path = File.join(Drank::Config.zk_prefix, "container-hosts")

      Drank::Log.info("URI: #{Drank::Config.uri}")
      Drank::Log.info("ZK: #{Drank::Config.zookeeper}")
      Drank::Log.info("Interval: #{Drank::Config.interval}")
      Drank::Log.info("Hostname: #{@hostname}")

      zk_container_host_session = Zookeeper.new(Drank::Config.zookeeper)

      # setup initial zk paths
      zk_init(zk_container_host_session)

      # create ephemeral node for host where drank is currently running
      create_container_host(zk_container_host_session)

      container_sessions = {}

      loop do
        Drank::Log.info("Lurkin' for containers ...")

        # loop through containers on this host creating zk sessions for each container
        containers = Drank::Docker.get_containers()

        current_containers = []

        containers.each do |cntr|
          unless container_sessions[cntr["Id"]]
            Drank::Log.info("Found new container (#{cntr["Id"]})")

            begin
              cntr_sess = Zookeeper.new(Drank::Config.zookeeper)
              create_container(cntr_sess, cntr["Id"]) # sets data too
              container_sessions.store(cntr["Id"], cntr_sess) # finally store the session for use later
            rescue Exception => e
              Drank::Log.error("Could not create session for #{cntr["Id"]}")
              raise
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
      Drank::ZK.create(session, {:path => @container_host_zk_path, :recursive => true})
      Drank::ZK.create(session, {:path => @service_zk_path, :recursive => true})
    end

    def self.create_container_host(session)
      # create container host path
      Drank::ZK.create(session, {
        :path => Drank::Utils.get_container_host_zk_path(@container_host_zk_path, @hostname),
        :recursive => true,
        :ephemeral => true,
        :data => Drank::Docker.get_version().to_json
      })
    end

    def self.create_container(session, id)
      # create service/container path
      data = Drank::Docker.get_container(id)
      service_name = Drank::Utils.get_container_service(data)

      # create service path if needed
      Drank::ZK.create(session, {
        :path => File.join(@service_zk_path, service_name)
      })

      service_path = File.join(@service_zk_path, service_name, @hostname)

      Drank::ZK.create(session, {
        :path => service_path
      })

      begin
        path = Drank::Utils.get_container_zk_path(service_path, data)

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

  end
end
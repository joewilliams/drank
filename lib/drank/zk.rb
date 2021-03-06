module Drank
  class ZK

    def self.new()
      session = Zookeeper.new(Drank::Config.zookeeper)
      check_connection(session) # make sure we are connected to zk
      session
    end

    def self.create(session, options = {:recursive => true, :ephemeral => false})
      if options[:recursive]
        create_path_recursive(session, options)
      else
        create_path(session, options)
      end
    end

    def self.create_path_recursive(session, options = {})
      # delete :recursive since its not a zk lib option
      options.delete(:recursive)

      dirs = []
      path = options[:path]

      while path.length >= 2 do
        split = File.split(path)
        path = split.first
        dirs = dirs + [split.last]
      end

      dirs.reverse!

      dirs.each do |dir|
        path = File.join(path, dir)
        options.store(:path, path)
        create_path(session, options)
      end
    end

    def self.create_path(session, options = {})
      get_result = session.get(:path => options[:path])

      unless get_result[:stat].exists
        create_result = session.create(options)
        Drank::Log.info("Created #{options[:path]}")
        Drank::Log.debug(create_result)

        if create_result[:path] == nil
          raise("Could not create #{options[:path]} with #{options}")
        end
      end
    end

    def self.check_connection(session)
      unless session.connected?
        raise("Not connected to ZK!")
      end
    end
  end
end
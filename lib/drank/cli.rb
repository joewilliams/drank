module Drank
  class CLI
    include Mixlib::CLI

    option :log_level,
      :short => "-l LEVEL",
      :long  => "--log_level LEVEL",
      :description => "Set the log level (debug, info, warn, error, fatal)",
      :default => :info,
      :proc => Proc.new { |l| l.to_sym }

    option :uri,
      :short => "-u URI",
      :long  => "--uri URI",
      :default => "unix:///var/run/docker.sock",
      :description => "URI for the docker socket, generally 'unix:///var/run/docker.sock' or 'tcp://host:port'"

    option :interval,
      :short => "-i SECONDS",
      :long => "--interval SECONDS",
      :default => 5,
      :description => "The amount of time in seconds that Drank will read from Docker and send a pulse to Zookeeper"

    option :zookeeper,
      :short => "-z host:port",
      :long  => "--zookeeper host:port",
      :default => "localhost:2181",
      :description => "ZooKeeper host and port"

    option :zk_prefix,
      :short => "-p PATH",
      :long  => "--zk-prefix PATH",
      :default => "/docker",
      :description => "Where Drank should store state"

    option :help,
      :short => "-h",
      :long => "--help",
      :description => "Show this message",
      :on => :tail,
      :boolean => true,
      :show_options => true,
      :exit => 0

  end
end
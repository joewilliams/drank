require 'rubygems'

require 'socket'
require 'uri'
require 'excon'
require 'zookeeper'
require 'mixlib/cli'
require 'mixlib/config'
require 'mixlib/log'
require 'yajl/json_gem'


__DIR__ = File.dirname(__FILE__)

$LOAD_PATH.unshift __DIR__ unless
  $LOAD_PATH.include?(__DIR__) ||
  $LOAD_PATH.include?(File.expand_path(__DIR__))

require 'drank/config'
require 'drank/log'
require 'drank/cli'
require 'drank/service'
require 'drank/zk'
require 'drank/docker'
require 'drank/utils'

module Drank
  class << self

    def main
      cli = Drank::CLI.new
      cli.parse_options
      Drank::Config.merge!(cli.config)

      Drank::Log.level(Drank::Config.log_level)

      Drank::Log.info("Starting up Drank ...")
      Drank::Service.run()
    end

  end
end
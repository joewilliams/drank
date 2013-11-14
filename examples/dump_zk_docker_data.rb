#!/usr/bin/env ruby

require 'rubygems'

require 'zookeeper'
require 'yajl/json_gem'

CONTAINER_HOSTS = "/docker/container-hosts"
SERVICES = "/docker/services"

zk = Zookeeper.new("localhost:2181")

container_hosts = zk.get_children(:path => CONTAINER_HOSTS)

container_hosts[:children].each do |ch|
  data = zk.get(:path => "#{CONTAINER_HOSTS}/#{ch}")
  puts "######################"
  puts "container host: #{ch}"
  puts "data: #{data[:data]}"
  puts "######################"
  puts ""
end

services = zk.get_children(:path => SERVICES)

services[:children].each do |svc|
  puts "######################"
  puts "service: #{svc}"

  hosts = zk.get_children(:path => "#{SERVICES}/#{svc}")

  hosts[:children].each do |host|
    puts "container host: #{host}"
    puts ""

    containers = zk.get_children(:path => "#{SERVICES}/#{svc}/#{host}")

    containers[:children].each do |cntr|
      puts "container: #{cntr}"
      data = zk.get(:path => "#{SERVICES}/#{svc}/#{host}/#{cntr}")

      puts "data: #{data[:data]}"
      puts ""
    end
  end

  puts "######################"
  puts ""
end
#!/usr/bin/env ruby

## this is a crappy little tester script
##
## run zookeeper, docker and drank on the same machine
##
## run this script and you should see drank consume
## docker data and send it to zk, killing sessions when
## containers die

loop do

  start_count = 5
  stop_count = 5

  start_count.times do
    out = `sudo docker run -d -e SERVICE=testservice -i -t ubuntu /bin/bash`
    puts "starting: #{out}"
    sleep 1
  end

  containers=`docker ps | awk '{print $1}' | grep -v CONTAINER | tail -n #{stop_count}`.split

  containers.each do |cont|
    out = `docker stop #{cont}`
    puts "stopping: #{out}"
  end

  sleep 3

end
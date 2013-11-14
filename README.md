### Drank

Drank is a service discovery daemon for Docker. Drank advertises container hosts, containers and their service state to ZooKeeper for consumption.


#### Usage

        $ drank # uses defaults

        # start a service using docker and drank should detect it, using the SERVICE environment variable
        $ sudo docker run -d -e SERVICE=testservice -i -t ubuntu /bin/bash


![](https://dl.dropboxusercontent.com/s/0dsib18j8jojoq8/2013-11-11%20at%205.50%20PM.png)


If you want to get the list of container hosts currently available for running docker containers, get the children of `/docker/container-hosts`.

If you want to get the list of currently running containers for a specific service, get the children of `/docker/services/SERVICENAME/CONTAINERHOST`. Each child will be a container for said service.

**Note that `/docker/services/SERVICENAME/CONTAINERHOST` is not an accurate listing of container hosts only use `/docker/container-hosts` for that**

````````
vagrant@precise64:~$ irb
irb(main):001:0> require 'zookeeper'
=> true

irb(main):002:0> zk = Zookeeper.new("localhost:2181")
=> #<Zookeeper::Client:0x00000000d731b0>

irb(main):003:0> zk.get_children(:path => "/docker/services")[:children]
=> ["testservice"]

irb(main):004:0> zk.get_children(:path => "/docker/container-hosts")[:children]
=> ["precise64"]

irb(main):005:0> zk.get_children(:path => "/docker/services/testservice/precise64")[:children]
=> ["de659d7ceaa1a212fac17ad419289a451ab683d76ae68f0cf37adefa1a8bbb69", "38d63f37a4d9ab3269ac5993264575ce7e7219831f7360bcca3b41ccea507ab1"]
````````

#### Hacking

You'll need to run inside a Vagrant VM if you are on Mac OS X. After checking out it out in your development environment, make accessible from inside a guest with a bit like thi sin Vagrantfile:

    Vagrant::VERSION >= "1.1.0" and Vagrant.configure("2") do |config|
      config.vm.synced_folder "/path/to/drank", "/drank"
    end

You'll need to `vagrant reload` to make it accessible. Then `vagrant ssh` to get inside.

    $ cd /drank
    $ script/setup
    $ bin/drank

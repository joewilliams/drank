### Drank

Drank is a service discovery daemon for Docker. Drank advertises container hosts, containers and their service state to ZooKeeper for consumption.


#### Usage

        $ drank

        $ drank -i 10 -u http://localhost:1234 -z localhost:2181


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
---
layout: page
permalink: /docker/networked-containers
---
# Networked Containers

This describes how to enable communication between containers thru a network.

1. Pull amazon linux

        docker pull amazonlinux

1. Create custom bridge network <code>my-network</code>

        docker network create --driver bridge my-network

1. Start 3 linux containers (<code>my-server-1</code> ,<code>my-server-2</code>, <code>my-client</code>), and add them to network <code>my-network</code>

        $cNames = "my-client", "my-server-1", "my-server-2"

        $cNames.ForEach({docker run -itd --name $_ --net=my-network amazonlinux})

1. The network should now has 3 containers

        docker network inspect my-network

1. Install <code>iputils</code> to <code>my-client</code> in order to ping the other containers.

        docker exec my-client yum -y install iputils

1. Container my-client should be able to ping the both servers

        docker exec my-client ping my-server-1
        docker exec my-client ping my-server-2

1. Clean up

        docker stop (docker ps -q)
        docker rm -f (docker ps -a -q)
        docker network rm my-network
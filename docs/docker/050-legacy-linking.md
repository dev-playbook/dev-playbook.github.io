---
layout: page
permalink: /docker/legacy-linking
---

# Legacy Linking

This describes how to link containers using legacy linking.

1. pull amazon linux

        docker pull amazonlinux

1. start a interactive and detached linux container, and give it a name <code>my-server</code>

        docker run -itd --name my-server amazonlinux

1. start another linux container named <code>my-client</code> and link it to <code>my-server</code>, with an alias <code>linux-server</code>

        docker run -itd --name my-client `
            --link my-server:linux-server `
            amazonlinux

1. Install iputils in order to do ping on <code>my-client</code>

        docker exec my-client yum -y install iputils

1. The client can ping the server either thru the server's name or alias

        docker exec my-client ping my-server
        docker exec my-client ping linux-server

1. Cleanup

        docker stop $(docker ps -q)
        docker rm -f $(docker ps -a -q)
---
layout: page
permalink: /docker/using-docker-compose
---
# Using Docker Compose

This is an example on how to create a networked containers using docker compose.

1. Create a working folder from the command prompt

        mkdir my-client-server

        cd my-client-server

1. Create file <code>client.dockerfile</code> with the following contents.

        FROM amazonlinux
        RUN yum -y install iputils

    When built, it creates an image based on <code>amazonlinux</code> with <code>iputils</code> installed.

1. Create file <code>docker-compose.yml</code> witht the following contents.

        version: '3.8'

        services:
            server-1:
                container_name: my-server-1
                image: amazonlinux
                stdin_open: true
                tty: true
                networks:
                    - my-network

            server-2:
                container_name: my-server-2
                image: amazonlinux
                stdin_open: true
                tty: true
                networks:
                    - my-network

            client:
                container_name: my-client-1
                build:
                    context: .
                    dockerfile: client.dockerfile
                stdin_open: true
                tty: true
                networks:
                    - my-network
        networks:
            my-network:
                driver: bridge

    The file describes how <code>docker-compose</code> will create containers.

    * 3 services are created: <code>server-1</code>, <code>server-2</code>, <code>client</code>
    * Their containers are named <code>my-server-1</code>, <code>my-server-2</code>, <code>my-client-1</code> respectively.
    * <code>server-1</code> and <code>server-2</code> are using the same <code>amazonlinux</code> image.
    * <code>client</code> image is built from <code>client.dockerfile</code> to allow 'ping'.
    * All are sharing the same bridge network <code>my-network</code>.
    * All have <code>stdin_open</code> and <code>tty</code> set to <code>true</code> to allow interactive terminal attachments.
    
1. Build and start the services in detach mode.

        docker-compose build

        docker-compose up -d

1. All 3 services should be running

        docker-compose images

1. The client should be able to communicate to both servers.

        docker exec my-client-1 ping server-1

        docker exec my-client-1 ping server-2

1. Stop <code>server-1</code> and the client wont see the server.

        docker-compose stop server-1

        docker exec my-client-1 ping server-1

1. Start <code>server-1</code> and the client will see the server.

        docker-compose start server-1

        docker exec my-client-1 ping server-1

1. Stop all services and remove their containers and networks.

        docker-compose down
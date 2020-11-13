---
layout: page
title:
permalink: /docker/hook-volume-nodejs-env
---

# Hook Volume To A NodeJs Environment

This describes the procedure on how to map a local nodejs development environment to a running container.

1. Start a command prompt and create a working directory

        mkdir www-nodejs

        cd www-nodejs

1. Execute the following commands to create a node environment and install an express website to <code>/ExpressSite</code>

        npm install -g express-generator

        npm init -y

        npm install express

        express ExpressSite --view=hbs

        npm install

1. Pull the latest node image

        docker pull node:latest

1. Create file <code>env.list</code> with the following content.

        DEBUG=expresssite:*
        PORT=1234

1. Start a docker container

        docker run --name my-www -d`
            -p 8080:1234 `
            -w "/var/www" `
            -v "$pwd/ExpressSite:/var/www" `
            --env-file env.list
            node:latest `
            npm start

    This will run as follows
    * <code>-d</code> will execute the container at the background
    * <code>-p</code> maps external port 8080 to internal port 1234
    * <code>-w</code> sets the container's working directory
    * <code>-v</code> mounts the <code>./ExpressSite</code> folder to the container's working directory
    * environment variables listed in <code>env.list</code> are applied

    Check the container is running

        docker ps -a --filter name=my-www

    Inspect the container and the volumn mounts under <code>HostConfig.Mounts</code>

        docker inspect my-www | Out-Host -Paging

1. Test the site

        Start-Process 'http://localhost:8080'

1. Clean up. Stop and remove the container

        docker stop my-www
        docker rm my-www
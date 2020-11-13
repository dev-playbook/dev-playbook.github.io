---
layout: page
title:
permalink: /docker/hook-volume-aspnet-env
---

# Hook Volume To ASP.NET Environment

This describes the procedure on how to map a local .net mvc development environment to a running container.

1. Start a command prompt and create a working directory

        mkdir www-aspnet

        cd www-aspnet

1. Pull the dotnet core SDK tagged by version

        docker pull mcr.microsoft.com/dotnet/core:3.1

1. List the dotnet SDKs installed and ensure that version 3.1.* exists. Otherwise, you will need to install.

        dotnet --list-sdks

1. Execute the following commands to create a ast.net

        dotnet new mvc --name my-www

1. Create file <code>env.list</code> with the following content.

        ASPNETCORE_URLS=http://*:1234
        ASPNETCORE_ENVIRONMENT=development

1. Delete the launch profiles

        Remove-Item ./my-www/Properties -Force

1. Start a docker container

        docker run --name my-www -d`
            -p 8080:1234 `
            -w "/app" `
            -v "$pwd/my-www:/app" `
            --env-list env.list
            mcr.microsoft.com/dotnet/core/sdk:3.1 `
            dotnet run

    This will run as follows
    * <code>-d</code> will execute the container at the background
    * <code>-p</code> maps external port 8080 to internal port 1234
    * <code>-w</code> sets the container's working directory
    * <code>-v</code> mounts <code>/my-www</code> folder to the container's working directory
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
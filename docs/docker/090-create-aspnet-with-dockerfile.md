---
layout: page
title:
permalink: /docker/create-aspnet-dockerfile
---
# Create ASP.net With Dockerfile

This shows the procedure on how to create and test an image of an asp.net website using a docker file.

## Set up development environment

1. Start a command prompt and create a working directory

        mkdir www-aspnet

        cd www-aspnet

1. List the dotnet SDKs installed and ensure that version 3.1.* exists. Otherwise, you will need to install.

        dotnet --list-sdks

1. Execute the following commands to create a asp.net environment in <code>/my-www</code>

        dotnet new mvc --name my-www

1. Create a Dockerfile <code>dev.dockerfile</code> with the following contents.

        FROM mcr.microsoft.com/dotnet/core/sdk:3.1
        LABEL author="I did this"
        ENV ENV ASPNETCORE_URLS=http://*:3000
        ENV DOTNET_USE_POLLING_FILE_WATCHER=1
        ENV ASPNETCORE_ENVIRONMENT=development
        WORKDIR /app
        ENTRYPOINT ["/bin/bash", "-c", "dotnet restore && dotnet watch run"]

1. Build an image from the working folder, with a given tag.

        docker build -f dev.dockerfile -t dev-www-aspnet .

    The build process is a follows 
    * sets the base image to the latests image of dotnet core sdk
    * sets the container's environment variables
    * sets the container's working directory to <code>/app</code>
    * on entry, it restores the site's package dependencies, runs the site and watches for any changes by the developer
    * names the image as <code>dev-www-aspnet</code>

    Check if the images was created

        docker images dev-www-aspnet

    Inspect the image created

        docker inspect dev-www-aspnet | Out-Host -Paging

1. Run a container from the image <code>dev-www-aspnet</code>

        docker run --name dev-www -d -v "$(pwd)/my-www:/app" -p 8080:3000 dev-www-aspnet

    * <code>-d</code> will execute the run in the background
    * <code>dev-www</code> is the container name
    * external port <code>8080</code> will map to the interal port <code>3000</code>.
    * mounts <code>/my-www</code> to the container's working directory

    Check that the container is running.

        docker ps -a filter=dev-www

    Inspect the running container

        docker inspect dev-www

1. From the browser, navigate to <code>http://localhost:8080</code> to test the site.

        Start-Process http://localhost:8080

## Production Build Setup (Manual)

1. Create a dockerfile <code>prod.dockerfile</code> with the following contents.


        FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as build
        WORKDIR /src
        COPY ["my-www.csproj", "./"]
        RUN dotnet restore ./my-www.csproj
        COPY . .
        WORKDIR /src/.
        RUN dotnet build ./my-www.csproj -c Release -o /app/build

        FROM build AS publish
        RUN dotnet publish "./my-www.csproj" -c Release -o /app/publish

        FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 as final
        WORKDIR /app
        ENV ASPNETCORE_URLS=http://*:3000
        EXPOSE 3000
        COPY --from=publish /app .
        VOLUME /app
        ENTRYPOINT ["dotnet", "my-www.dll"]

1. Build an image from the working folder, with a given name.

        docker build -f prod.dockerfile -t prod-www-aspnet .

    The build process is as follows
    * creates <code>build</code> container with <code>/src</code> as its working directory.
    * copies the <code>csproj</code> file to the working directory and restores the dependencies.
    * copies the content of <code>/www-aspnet</code> to the working directory and calls <code>dotnet</code> to execute a <code>Release</code> build to <code>/app</code>
    * create <code>final</code> container, whose
        * working directory as <code>/app</code>
        * copies <code>/app</code> from the <code>publish</code> container to the working directory
        * exposes port <code>3000</code>
        * sets the container's entrypoint to the published dll

    Check if the images was created

        docker images prod-www-aspnet

    Inspect the image created

        docker inspect prod-www-aspnet | Out-Host -Paging

1. Run a container from the image <code>prod-www-aspnet</code>

        docker run --name prod-www -d -p 8181:3000 proc-www-aspnet

    * <code>-d</code> will execute the run in the background
    * <code>prod-www</code> is the container name
    * external port <code>8181</code> maps to the interal port <code>3000</code> as exposed by the docker file.

    Check that the container is running.

        docker ps -a filter=prod-www

    Inspect the running container

        docker inspect prod-www

1. Open a browser and test the site.

        Start-Process http://localhost:8181

## Production Build Setup (Visual Studio Code)

1. Open Visual Studio Code, open the working folder.
1. Open the command pallette (<code>Ctrl-Shift-P</code>) and select <code>.NET: Generate Assets for Build and Debug</code>. Ensure that folder <code>.vscode</code>.
1. Ensure you have <code>Docker</code> extension installed, open the command pallete and select the following sequence to create <code>Dockerfile</code>.

        Docker: Add Docker Files To Workspace
        Application Platform: .NET: ASP.NET Core
        Operating System: Linux
        Ports: 5000
        Include Docker Compose Files: No

1. Delete <code>launchProperties</code> folder 
1. From <code>Dockerfile</code> add this line under '<code>FROM base AS final</code>'

       ENV ASPNETCORE_URLS=http://*:5000

1. Right click on <code>Dockerfile</code> and select <code>Build Image</code>. This creates image whose name is taken from the project file name (in this case <code>wwwaspnet</code>).
1. Open the Docker tool, right-click on image created and select run.
1. Open a browser and test the site.

        Start-Process http://localhost:5000

## Clean Up

1. Cleanup. Stop all containers and remove all containers and images.

        docker stop (docker ps -a -q)
        docker rm (docker ps -a -q)
        docker rmi (docker images *www*aspnet -q)
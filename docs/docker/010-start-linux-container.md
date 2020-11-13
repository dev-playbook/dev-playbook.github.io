---
layout: page
title: Start an interactive Linux container
permalink: /docker/start-linux-container
---

# Start an interactive Linux container

This procedure describes how to start and interactive Linux container.

1. Pull the latest image of <code>amazonlinux</code>

        docker pull amazonlinux:latest

1. Navigate to your working folder.

1. Create a container of the image

        docker run -it `
          -v "$(pwd):/usr/$(hostname)"
          --rm `
          --name my-linux `
          amazonlinux
          
    Where 
    * <code>-i</code> and <code>-t</code> runs the container on an interactive terminal
    * <code>-v</code> mounts the current working folder to the container directory <code>/usr/[hostname]</code>, where <code>hostname</code> is the machine name.
    * <code>--rm</code> automatically removes the container on exit

1. From the bash shell, navigate to <code>/usr/temp</code> to find the contents of the working folder.
    
        cd /usr/temp

1. <code>Ctrl-Shift-P</code> to detach from container. To reattach, execute the following:

        docker attach my-linux

1. From the bash shell, enter <code>exit</code> to exit the container.
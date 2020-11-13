---
layout: page
title:
permalink: /docker/create-run-linux-image
---

# Create and run a Linux image

This procedure describes how to create, update and commit a linux container.

1. Pull the latest image of <code>amazonlinux</code>

        docker pull amazonlinux:latest

1. Create a container of the image

        docker run -it --name my-linux amazonlinux

    Where <code>-i</code> and <code>-t</code> runs the container on an interactive terminal

1. From the bash shell, execute the following in sequence:
    
        yum -y update
        export PS1="[\u]\w >"
        echo 'updated by me' > update-msg.txt
        exit

   This will
   * update the OS
   * change the prompt format
   * save a text file with a small message
   * exit

1. Commit container to image with a given name, and confirm that the new image exists.

        docker commit my-linux my-amazonlinux

        docker images my-amazonlinux

1. Remove container
    
        docker rm my-linux

1. Run container with image with given tag

        docker run -it --name my-linux my-amazonlinux

1. From bash shell, find the small message, and exit

        # cat update-msg.txt
        # exit

1. Stop and remove container, and remove tagged image
        
        docker rm my-linux
        docker rmi my-amazonlinux
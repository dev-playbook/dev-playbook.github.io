---
layout: page
title:
permalink: /docker/tag-publish-image
---
# Tag and Publish Image

This show an example on how to tag and publish an image, in this case an amazon linux image.

1. Login to your repository hub account.

        docker login -u [username] -p [password] -H [host]

    If <code>-H</code> is empty, then it defaults to <code>docker.io</code>.

1. Pull the latest <code>amazonlinux</code> image

        docker pull amazonlinux

1. Create <code>latest</code> and <code>v1</code> tag to the image <code>[username]/amazonlinux</code>

        docker tag amazonlinux:latest [username]/amazonlinux

        docker tag amazonlinux:latest [username]/amazonlinux:v1

1. Push the tags to the repository

        docker push [username]/amazonlinux

1. Remove the local images

        docker rmi [username]/amazonlinux

1. Pull the image tagged <code>latest</code> from the repository and confirm its existence

        docker pull [username]/amazonlinux

        docker images */amazonlinux

1. Pull the image tagged <code>v1</code> from the repository and confirm its existence

        docker pull [username]/amazonlinux:v1

        docker images */amazonlinux

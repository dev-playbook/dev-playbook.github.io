---
layout: page
permalink: /docker/create-nodejs-www-dockerfile
---
# Create NodeJs Site With Dockerfile

This shows the procedure on how to create and test an image of simple node js website using docker file.

1. Start a command prompt and create a working directory

        mkdir www-nodejs

        cd www-nodejs

2. Execute the following commands to create a node environment and install an express website to <code>/ExpressSite</code>

        npm install -g express-generator

        npm init -y

        npm install express

        express ExpressSite --view=hbs

        SET DEBUG=expresssite:*

1. Create a Dockerfile file with the following contents.

        FROM node:latest
        LABEL author="I did this"
        ENV NODE_ENV=production
        ENV PORT=3000
        COPY ./ExpressSite /var/www
        WORKDIR /var/www
        RUN npm install
        VOLUME ["/var/www"]
        EXPOSE $PORT
        ENTRYPOINT ["npm", "start"]

1. Build an image from the working folder, with a given tag.

        docker build -t my-www-nodejs .

    The build will 
    * sets the base image to the latests image of <code>node</code>
    * sets the container's environment variables, including the port number
    * copy the contents of the working directory <code>./</code> to the container's <code>/var/www</code>
    * sets the container's working director to <code>/var/www</code> and a volume will be mapped.
    * installs all dependencies using node package manager (npm)
    * exposes the port for traffic
    * set the entry point <code>npm start</code>
    * tags the image to <code>my-www-nodejs</code>

    Check if the images was created

        docker images my-www-nodejs

    Inspect the image created

        docker inspect my-www-nodejs

1. Run a container from the image <code>my-www-nodejs</code>

        docker run -d --name my-www -p 8080:3000 my-www-nodejs

    * <code>-d</code> will execute the run in the background
    * <code>my-www</code> is the container name
    * external port <code>8080</code> will map to the interal port <code>3000</code> as exposed by the docker file.

    Check that the container is running.

        docker ps -a filter=my-www

    Inspect the running container

        docker inspect my-www

1. From the browser, navigate to <code>http://localhost:8080</code> to test the site.

        Start-Process http://localhost:8080

1. Cleanup. Stop the container and remove the container and image.

        docker stop my-www
        docker rm -v my-www
        docker rmi my-www-nodejs


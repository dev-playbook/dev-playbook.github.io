---
title: Azure Web Apps and Docker Compose YAML
index: 70
layout: post
date: 2020-11-24 09:00
categories: 
    - Azure CLI
    - Azure WebApps
permalink: azure-cli/webapps/docker-compose-yaml
tags: 
    - devops
    - docker
    - docker-compose
description: Azure allows deployment of worker instances from a docker-compose script. This tutorial shows the process of deploying instances for WordPress and database servers using an Azure's docker-compose sample.
---
>tl;dr
>```shell
># create a web app using a docker compose yaml file
>az webapp create -n {app name} -g {group name} 
>       --plan {appservice plan} \
>       --multicontainer-config-type compose \
>       --multicontainer-config-file {docker compose yaml file}
>```

## **Introduction**

{{page.description}} **Note that this tutorial will be using the [Basic Service Plan for Linux](https://azure.microsoft.com/en-gb/pricing/details/app-service/linux/){:target="_blank"}**.

{% include az-cli/000-prerequisites.md %}

## **Prepare**
{%include az-cli/005-login-account.md%}
{% include az-cli/010-create-resource-group.md %}

## **Create Web App**

{% include az-cli/020-create-app-service.md sku="B1" %}

    Basic tier it is the minimum required for instantiating multiple containers.

1. Get the code sample from Azure Samples and change directory.

    ```shell
    git clone https://github.com/Azure-Samples/multicontainerwordpress

    cd multicontainerwordpress
    ```

    Open <code>docker-compose-wordpress.yml</code> and you should see the following content.
    ```yml
    version: '3.3'
    services:
        db:
            image: mysql:5.7
            volumes:
                - db_data:/var/lib/mysql
            restart: always
            environment:
                MYSQL_ROOT_PASSWORD: somewordpress
                MYSQL_DATABASE: wordpress
                MYSQL_USER: wordpress
                MYSQL_PASSWORD: wordpress
        wordpress:
            depends_on:
                - db
            image: wordpress:latest
            ports:
                - "8000:80"
            restart: always
            environment:
                WORDPRESS_DB_HOST: db:3306
                WORDPRESS_DB_USER: wordpress
                WORDPRESS_DB_PASSWORD: wordpress
    volumes:
        db_data:
    ```
    The script shows 2 services to be created; a <code>wordpress</code> container and its dependency <code>db</code> being a MySql container.
    
1. Create the app from the docker-compose script.

    ```shell
    appname=webapp-demo-$RANDOM

    az webapp create --plan $planname --name $appname \
        --multicontainer-config-type compose \
        --multicontainer-config-file docker-compose-wordpress.yml

    az configure --defaults web=$appname
    ```

    Note that the webapp name is added to the configured defaults for the azure cli. From here on, subsequent `az` commands will omit argument for <code>--name</code> (of web app).

{% include az-cli/040-browse-webapp.md %}

    If you receive an error, retry a few minutes to allow WordPress to initialize. If you're having trouble and would like to troubleshoot, review container logs on the next step.

1. Download the app logs.

    ```shell
    az webapp log download
    ```

    Unpack the downloaded package and open <code>*_docker.log</code> file from the _/LogFiles_ folder. Expect [INFO] entries regarding the pulling, extracting, verifying, and downloading of images from Docker Hub. Also expect <code>docker run</code> entries indicating the instantiation the containers <code>webapp-demo-*_db_*</code> and <code>webapp-demo-*_wordpress_*</code>.
    >You can also view the same docker logs from the [Kudu Source Control Manager](https://azure.microsoft.com/en-gb/resources/videos/what-is-kudu-with-david-ebbo/) portal of the app.
    >```
    >xdg-open https://$appname.scm.azurewebsites.net/api/logs/docker
    >```

## **Clean up**

{% include az-cli/999-cleanup.md %}
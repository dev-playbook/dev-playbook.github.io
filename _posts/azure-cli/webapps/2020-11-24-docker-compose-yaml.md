---
title: Azure Web Apps with Docker Compose YAML
index: 50
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
>az webapp create --plan $planname --name $appname \
>     --multicontainer-config-type compose \
>     --multicontainer-config-file {docker compose yaml file}
>```
{{page.description}} **Note that the process requires the chargeable [Basic Service Plan for Linux](https://azure.microsoft.com/en-gb/pricing/details/app-service/linux/){:target="_blank"}**.

## **Preperations**

1. Ensure that you are logged in to your Azure Account.

    ```shell
    az account show
    # if not, login
    az login
    ```

1. Create a resource group in West UK where the web app will be deployed.

    ```shell
    rg='webapp-demo-rg'
    location='ukwest'
    az group create --name $rg --location $location --verbose
    ```
    Results should include details of the new group including allocated id and _provising state_ as _Succeeded_.

1. Configure the Azure CLI to use default arguments and confirm.
    
    ```shell
    az configure --defaults group=$rg location=$location
    az configure --list-defaults --output table
    ```
    The configured defaults should include values for _group_ and _location_. From here on, subsequent <code>az</code> commands will omit arguments for <code>--resource-group</code> and <code>--location</code>.

## **Creation**

1. Create an Azure App Service Plan with B1 SKU in the Linux platform

    ```shell
    planname='webapp-demo-asplan'
    az appservice plan create --name $planname --sku B1 --is-linux --verbose
    ```
    Results should include details of the new service plan, including its Id, SKU details and provisioning state as _Succeeded_.

    B1 SKU belongs to the Basic pricing tier group and it is the minimum required for instantiating multiple containers.
    > Basic is a production-grade tier for low traffic requirements. It has the following features and limitations.
    > - Uses _dedicated virtual machines_ allowing scaling out to multiple instances.
    > - Limited to _manual scaling_.
    > - Allows for _customised domains_ and the use of _ssl certificates_
    > - _No deployment slots_ for staging environments.

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

    Note that the webapp name is added to the configured defaults for the azure cli. From here on, subsequent <code>az</code> commands will omit arguments for <code>--resource-group</code>, <code>--location</code> and <code>--name</code> (of web app).

1. Open the WordPress site.

    ```shell
    az webapp browse --logs
    ```

    If you receive an error, retry a few minutes to allow WordPress to initialize. If you're having trouble and would like to troubleshoot, review container logs.

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

1. Delete all resources created in the group, including the web app and app service.

    ```shell
    az group delete --yes
    ```

### Further Reading

- [Tutorial: Deploy a multi-container group using Docker Compose](https://docs.microsoft.com/en-us/azure/container-instances/tutorial-docker-compose)
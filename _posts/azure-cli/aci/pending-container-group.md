---
title: Container Group with Docker Compose
index: 50
#layout: post
date: 2099-01-01 00:00
categories: 
    - Azure CLI
    - Azure Container Registry
    - Azure Container Instances
    - Docker Compose
permalink: azure-cli/aci/container-group
tags: 
    - devops
    - docker
    - docker-compose
description: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse bibendum quis felis eget efficitur. Praesent elementum lacus mauris, et rhoncus odio mattis at. Donec quis purus quis nunc pretium condimentum. Donec ut mauris sapien. Nullam facilisis luctus nisl, nec accumsan ligula. Duis dignissim varius sem eget tempus. Proin id tellus in nibh tempus lobortis. Aliquam ut ex a velit feugiat suscipit sit amet eget mauris. Sed elementum dui et velit blandit, sed elementum nisl fermentum.
---
>tl;dr
>```bash
># create an azure container repository
>az acr create -g {resource group name} \
>        --name {repo name} \
>        --sku {Basic|Classic|Premium|Standard}
>
># login to azure container repository
>az acr login --name {repo name}
>
># build container image
>docker-compose up --build -d
>
># stop application and remove containers
>docker-compose down
>
># deploy the application to azure container instances
>docker-compose push
>
># show image registered in repository
>az acr repository show --name {repo name} --repository {image name}
>
># login to azure with docker
>docker login azure
>
># create azure container instance context
>docker context create aci {aci context name}
>
># list docker contexts
>docker context ls
>
># start applicaiton in the azure container instances
>docker compose up
>
># view active containers in the azure container instances
>docker compose up
>
># view logs
>docker logs {container id}
>
># logout azure
>docker logout
>```

## **Introduction**

{{page.description}}

{%include az-cli/000-prerequisites.md%}
- docker desktop installed version 2.3 or later

## **Prepare**
{%include az-cli/005-login-account.md%}
{% include az-cli/010-create-resource-group.md location="us"%}

    >Not all locations support the <code>Microsoft.ContainerInstance/containerGroups</code> resource type. To list all supported locations, run this query.
    >```
    >az provider list --query "[].resourceTypes[?resourceType=='containerGroups'].locations"
    >```

## **Create Container Registry**

1. Create an Azure container registry.

    ```shell
    acrname=webappdemoacr$RANDOM
    az acr create --name $acrname --verbose --sku Basic

    az configure --defaults acr=$acrname
    az configure --list-defaults --output table
    ```
    The <code>az acr create</code> results should include details of the registry including provisioning state _Succeeded_, name and login server <code>{acrname}.azureacr.io</code>. 

    Note that the container name is randomised to ensure uniqueness within Azure.

    > When naming the container registry, Microsoft suggests using lowercased names to avoid authentication errors using the server url in docker commands.

    Also, defaults for _acr_ has been added to Azure cli. From here on, subsequent <code>az</code> commands will omit arguments to <code>--name</code> (of registry).

    >Basic SKU is blah blah blah
    >Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc dapibus sem erat, vitae faucibus nibh hendrerit id. Nunc lacinia semper nibh, ut cursus diam convallis eget. Integer luctus feugiat posuere. Proin ultricies a nisi a fermentum. Curabitur sem arcu, scelerisque mollis nibh sit amet, volutpat volutpat ante.

1. Login to the container registry.

    ```shell
    az acr login --verbose
    ```
    This will obtain an Azure Active Directory refresh token, and execute a <code>docker login</code> to server <code>{acrname}.azureacr.io</code>. 
    
    Expect a <code>Login Succeeded</code> result.
    >The script used to login to docker can be viewed by executing the following.
    >
    >```
    >az acr login --expose-token --verbose
    >```

## **Build a Sample Application Locally**

1. Clone a Voting App from Azure Samples and change directory.

    ```shell
    git clone https://github.com/Azure-Samples/azure-voting-app-redis.git

    cd azure-voting-app-redis
    ```

1. View the Docker Compose file.

    ```shell
    cat docker-compose.yaml
    ```
    Expect to see two services specified as follows:
    + <code>azure-vote-back</code> is the data storage service and it is instantiated from a _redis_ v6 image pulled from Microsoft's registry.
    + <code>azure-vote-front</code> is the front end service, who's build sourced from <code>./azure-vote</code> sub-directory, and resulting image built is tagged as <code>mcr.microsoft.com/azuredocs/azure-vote-front:v1</code>

1. Modify the Docker Compose file.

    ```shell
    acrLoginServer=$(az acr show --query loginServer | sed 's/["\r ]//g')
    echo $acrLoginServer

    cat docker-compose.yaml \
        | sed -E "s;image: .+azure-vote-front.*;image: $acrLoginServer/azure-vote-front;g" \
        | sed -E "s;..80:80;80:80;g" > docker-compose.yaml

    cat docker-compose.yaml
    ```
    The registry details are obtained and the <code>loginServer</code> is extracted.
    
    Next, the <code>docker-compose.yaml</code> is modified so that the <code>azure-vote-front</code> service uses builds the image with a tag referencing the ACR login server and instantiates with a different port mappings. Hence, you should see <code>image:</code> and <code>ports:</code> values to the service in the YAML file as follows.
    ```
    azure-vote-front:
        ...
        image: {acrname}.azurecr.io/azure-vote-front
        ...
        ports:
            - "80:80"
    ```

1. Run the sample application locally.

    ```shell
    docker-compose up --build -d

    xdg-open http://localhost
    ```
    You should see <code>azure-vote-front</code> being built and all its dependent images being pulled from their source registries and cached locally.

    From the browser you should see the Azure Voting App.
    >Ensure that no other web server mapped to port 80 is hosted on your machine.

1. List the container images.
    ```shell
    {% raw %}docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"{% endraw %}
    ```
    The resulting table should include docker images identifiable by their repository name and tag. This should include the voting app built and its dependent _redis v6_ image pulled from Microsoft's registry, as specified by <code>docker-compose.yaml</code>.
    ```
    REPOSITORY                                          TAG
    {acrname}.azurecr.io/azure-vote-front               latest
    mcr.microsoft.com/oss/bitnami/redis                 6.0.8
    ```

1. List the running containers.
    ```shell
    {% raw %}docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"{% endraw %}
    ```
    The resulting table should list active containers running images taken from your local repository, including the 2 services specified by <code>docker-compose.yaml</code>.
    ```
    NAMES               IMAGE
    azure-vote-front    {acrname}.azurecr.io/azure-vote-front
    azure-vote-back     mcr.microsoft.com/oss/bitnami/redis:6.0.8
    ```

1. Stop the voting app.
    ```shell
    docker-compose down
    ```
    You should see both <code>azure-vote-front</code> and <code>azure-vote-back</code> containers being stopped and removed.

## **Deploy to Azure Container Instances**

1. Push images to the Azure Container Registry.
    ```shell
    docker-compose push
    ```
    This reads the <code>docker-compose.yaml</code> file and pushes the <code>azure-vote-front</code> image to the registry. The <code>azure-vote-back</code> image is not pushed as it is pulled from Microsoft's own registry when the voting app is instantiated.

    You may have to wait a few minutes for this to complete.

1. View the pushed image.
    ```shell
    az acr repository show --repository azure-vote-front
    ```
    Expect to results confirming image <code>azure-vote-front</code> in registry <code>{acrname}.azurecr.io<code>.

1. Login to Azure Container Instances.
    ```shell
    docker login azure
    ```
    This login call differs from the earlier call of <code>az acr login</code> (which is also calls <code>docker login</code>) as that authenticates access to the Azure Container Registry.

1. Create and verify an Azure Container Instances context
    ```shell
    acicontext=webapp-demo-acic
    docker context create aci $acicontext

    {% raw %}docker context ls --format "table {{.Name}}\t{{.Description}}"{% endraw %}
    ```
    When prompted, you will need to select resource group <code>webapp-demo-rg'</code> and, when necessary, your subscription Id.

    From the context list, expect to see the new context <code>webapp-demo-acic</code>.

1. Deploy application to ACI
    ```shell
    docker context use $acicontext

    docker compose up
    ```
    Note that the omitted hyphen as <code>docker compose</code> is the command available in an ACI context.

    Expect to see the following once completed.
    ```
    [+] Running 3/3
    - Group azurevotingappredis  Created
    - azure-vote-front           Done
    - azure-vote-back            Done
    ```

1. Verify the running containers.

    ```shell
    docker ps
    ```

    Expect to see a similar output below.
    ```
    CONTAINER ID                           IMAGE                                        
    azurevotingappredis_azure-vote-back    mcr.microsoft.com/oss/bitnami/redis:6.0.8
    azurevotingappredis_azure-vote-front   {acrname}.azurecr.io/azure-vote-front
    ```

1. Test the voting app.

    ```shell
    voteAppUrl=$(docker ps | grep vote-front | sed -E s/.+Running//g | sed -E s/:80.+//g | sed -E "s/ //g")

    xdg-open http://$voteAppUrl
    ```

1. View logs.
    ```shell
    docker logs azurevotingappredis_azure-vote-front
    ```

## **Clean Up**

1. Shut down the application and delete container group.
    ```shell
    docker compose down

    docker ps
    ```
    Expect an empty table of running instances.

1. Switch over to local default context and remove the ACI context.

    ```shell
    docker context use default

    docker context rm $acicontext

    docker context ls
    ```
    Expect to see <code>default</code> as the current context with (<code>*</code>).

{% include az-cli/999-cleanup.md%}
>To delete the container registry
>```
>az acr delete
>```


## **Further Reading**

- [Tutorial: Deploy a multi-container group using Docker Compose](https://docs.microsoft.com/en-us/azure/container-instances/tutorial-docker-compose)

- [Azure Container Registry documentation](https://docs.microsoft.com/en-us/azure/container-registry)
- [Azure Container Registry SKUs](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-skus)
- [Deploying Docker containers on Azure](https://docs.docker.com/engine/context/aci-integration/)
- [Creating the application Client ID and Client Secret](https://community.microfocus.com/t5/Identity-Manager-Tips/Creating-the-application-Client-ID-and-Client-Secret-from/ta-p/1776619)

- [WSL2 Now Supports Localhost Connections From Windows 10 Apps]https://www.bleepingcomputer.com/news/security/wsl2-now-supports-localhost-connections-from-windows-10-apps/
- [docker ps](https://docs.docker.com/engine/reference/commandline/ps/)
- [docker image](https://docs.docker.com/engine/reference/commandline/images/)


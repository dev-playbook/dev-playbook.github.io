---
layout: page
---

Ref: https://github.com/Azure-Samples/acr-helloworld
Ref: https://docs.microsoft.com/en-gb/azure/app-service/tutorial-multi-container-app


Ref: https://github.com/Azure-Samples/acr-helloworld
Ref: https://docs.microsoft.com/en-gb/azure/app-service/tutorial-multi-container-app

# Deploy using Docker Compose

Ref: https://docs.microsoft.com/en-us/azure/container-instances/tutorial-docker-cEastse

1. Open command line or PowerShell and login to azure

az login

1. Create a resource group and default subsequent commands to group and location East US

$rg = 'aci-demo-dockercompose-rg'

$location = 'eastus'

az group create --name $rg --location $location

az configure --defaults group=$rg location=$location

1. Create and login the a new Azure Container Repository

$acrname = "acidemoacr$(Get-Random)"

az acr create --name $acrname --sku Basic

az acr login --name $acrname

1. Get the sample application from Azure Samples

git clone https://github.com/Azure-Samples/azure-voting-app-redis.git

cd azure-voting-app-redis

1. Modify the docker compose file

cp .\docker-compose.yaml .\docker-compose.yaml.old

$dcContent = (cat .\docker-compose.yaml.old) -replace "8080:80", "80:80" 

$dcContent = $dcContent -replace "image:.+/azure-vote-front.+", "image: $acrname.azurecr.io/azure-vote-front"

$dcContent | Out-File .\docker-compose.yaml -Eneing UTF8

Service <code>azure-vote-front</code> should now have the image pointed to <code>azure-vote-front

docker-compose up --build -d

docker images

docker ps

docker-compose down

docker-compose push

## Create Azure Context

docker login azure

$acicontext = "aci-demo-aci"

docker context create aci $acicontext

docker context ls

## Deploy application to AC instances

docker context use $acicontext

docker compose up

docker ps

docker logs azurevotingappredis_azure-vote-front

docker compose down

az group delete --yes

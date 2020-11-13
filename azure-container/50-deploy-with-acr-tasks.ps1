-- -
layout: page
-- -

az login

$rg = "webapp-demo-acr-rg"

az group create --name $rg --location 'eastus'

az configure --defaults group=$rg location=eastus

$acrname = "webappdemoacr$(Get-Random)"

az acr create -n $acrname --sku Basic #  Basic, Classic, Premium, Standard

az acr login -n $acrname # --expose-token

echo 'FROM mcr.microsoft.com/hello-world' | Out-File Dockerfile -Encoding utf8

az acr build --image sample/hello-world:v1 --registry $acrname --file Dockerfile .

az acr run --registry $acrname --cmd '$Registry/sample/hello-world:v1' /dev/null


ref: https://github.com/Azure-Samples/acr-helloworld
ref: https://docs.microsoft.com/en-gb/azure/container-registry/container-registry-quickstart-task-cli
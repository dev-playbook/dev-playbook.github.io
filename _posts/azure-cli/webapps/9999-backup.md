---
title: Backup Azure Web App
index: 10
layout: post
date: 2020-12-03 12:00
categories: 
    - Azure CLI
    - Azure WebApps
permalink: azure-cli/webapps/backup
tags:
    - devops
    - backup
description: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi consectetur diam justo, quis viverra turpis rutrum ut. Praesent sodales sapien vel est venenatis, non luctus purus aliquam. Morbi euismod mattis erat et finibus. Sed ac purus sit amet orci convallis dictum. Sed euismod quis ipsum non porta. 
---

## **Introduction**

{{page.description}}
{%include az-cli/000-prerequisites.md%}

## **Prepare**

1. Complete either the _[introductory]({% link _posts/azure-cli/webapps/2020-11-15-introduction.md %})_ or _[GitHub deployment]({% link _posts/azure-cli/webapps/2020-11-17-github.md %})_ tutorial excluding Clean Up.

1. Confirm the NodeJS app is deployed and running.
    ```shell
    az webapp browse
    ```

1. Confirm the default arguments to `az` command for _group_ and _web_ are configured.
    ```shell
    az configure --list-defaults --output table
    ```

1. Ensure that variable $appname has the value of the web app's name.

    ```shell
    [[ -z "$appname" ]] && appname=$(az webapp show --query "name" --output tsv | sed -E "s/\r//g")
    echo $appname
    ```


#!/bin/bash

groupname="myResourceGroup"
planname="myAppServicePlan"
webappname=mywebapp$RANDOM
storagename=mywebappstorage$RANDOM
location="WestEurope"
container="appbackup"
backupname="backup1"
expirydate=$(date -I -d "$(date) + 1 month")

# Create a Resource Group 
az group create --name $groupname --location $location

# Create a Storage Account
az storage account create --name $storagename --resource-group $groupname --location $location \
--sku Standard_LRS

# Create a storage container
az storage container create --account-name $storagename --name $container

# Generates an SAS token for the storage container, valid for one month.
# NOTE: You can use the same SAS token to make backups in App Service until --expiry
sastoken=$(az storage container generate-sas --account-name $storagename --name $container \
--expiry $expirydate --permissions rwdl --output tsv)

# Construct the SAS URL for the container
sasurl=https://$storagename.blob.core.windows.net/$container?$sastoken

# Create an App Service plan in Standard tier. Standard tier allows one backup per day.
az appservice plan create --name $planname --resource-group $groupname --location $location \
--sku S1

# Create a web app
az webapp create --name $webappname --plan $planname --resource-group $groupname

# Create a one-time backup
az webapp config backup create --resource-group $groupname --webapp-name $webappname \
--backup-name $backupname --container-url $sasurl

# List statuses of all backups that are complete or currently executing.
az webapp config backup list --resource-group $groupname --webapp-name $webappname
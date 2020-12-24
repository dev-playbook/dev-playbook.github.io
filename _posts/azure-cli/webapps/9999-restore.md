---
title: Restore Azure Web App from Backup
index: 10
layout: post
date: 2020-12-03 12:00
categories: 
    - Azure CLI
    - Azure WebApps
permalink: azure-cli/webapps/restore
tags:
    - devops
    - restore
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
webappname="<replace-with-your-app-name>"

# List statuses of all backups that are complete or currently executing.
az webapp config backup list --resource-group $groupname --webapp-name $webappname

# Note the backupItemName and storageAccountUrl properties of the backup you want to restore

# Restore the app by overwriting it with the backup data
# Be sure to replace <backupItemName> and <storageAccountUrl>
az webapp config backup restore --resource-group $groupname --webapp-name $webappname \
--backup-name <backupItemName> --container-url <storageAccountUrl> --overwrite
---
title: Azure Web Apps with File Share
index: 10
layout: post
date: 2020-12-04 10:00
categories: 
    - Azure CLI
    - Azure WebApps
    - Azure Storage Account
permalink: azure-cli/webapps/file-share
tags:
    - devops
    - file sharing
description: This tutorial will show you how to create a storage file share from a storage account and attach it to a web app. 
---

>tl;dr
>```shell
># create storage account
>az storage account create --name {storage account name} --sku Standard_LRS
>
># create a storage share
>az storage share create --name {share name} \
>       --account-name {storage account name} --account-key {storage account key}
>az storage share create --name {share name} \
>       --connection-string {storage account connection string}
>
># upload a file to storage share
>az storage file upload --share-name {share name} \
>       --account-name {storage account name} --account-key {storage account key} \
>       --source {filename path}
>az storage file upload --share-name {share name} \
>       --connection-string {storage account connection string} \
>       --source {filename path}
>
># attach storage share to web app 
>az webapp config storage-account add --storage-type AzureFiles --share-name {share name} \
     --account-name {storage account name} \
     --access-key {storage account key} \
     --mount-path "/your-share-path" \
     --custom-id {your custom share identifier}
>```

## **Introduction**

{{page.description}} **Note that the process uses a storage account with the chargeable [Standard LRS](https://azure.microsoft.com/en-gb/pricing/details/storage/){:target="_blank"}**.
{%include az-cli/000-prerequisites.md%}

## **Prepare**

1. Complete the _[introductory tutorial]({% link _posts/azure-cli/webapps/2020-11-15-introduction.md %})_ excluding Clean Up.

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

## **Create Storage Account and Share**

1. Create a storage account

    ```shell
    storeaccname=webappdemostore$RANDOM
    az storage account create --name $storeaccname --sku Standard_LRS
    ```
    Expect the response to include `"provisioningState": "Succeeded"`.

    > To list existing storage accounts
    > ```
    > az storage account list
    > ```

    > Standard LRS stands for _Standard Locally Redundant Storage_. It uses hard disk drives based storage media, and are best suited for development, testing and infrequently accessed workloads.

1. Create a storage share.

    ```shell
    storeacckey=$(az storage account keys list --account-name $storeaccname --query [0].value --output tsv | sed -E "s/\r//g")
    echo $storeacckey

    sharename=myshare
    az storage share create --name $sharename --account-name $storeaccname --account-key $storeacckey
    ```
    Expect a `"created": true` response.

    >To list existing storage shares
    >```
    >az storage share list --account-name $storeaccname --account-key $storeacckey
    >```

    >To use a connection string to create the storage share.
    >```
    >connstr=$(az storage account show-connection-string --name $storeaccname --query connectionString --output tsv | sed "s/\r//g")
    >
    >az storage share create --name $sharename --connection-string $connstr
    >```

1. Upload a file to the storage share.

    ```shell
    echo "hello from az cli" > hello-from-cli.txt

    sharename=myshare
    az storage file upload --share-name $sharename \
        --account-name $storeaccname --account-key $storeacckey \
        --source hello-from-cli.txt --verbose
    ```

    >To use a connection string to upload a file to a storage share.
    >```
    >az storage file upload --share-name $sharename \
    >       --connection-string $connstr
    >       --source hello-from-cli.txt --verbose
    >```

## **Attach Storage File Share**

1. Add storage share to web app.

    ```shell
    shareId=myshare1
    az webapp config storage-account add --storage-type AzureFiles --share-name $sharename \
        --account-name $storeaccname \
        --access-key $storeacckey \
        --mount-path "/$sharename" \
        --custom-id $shareId \
        --verbose
    ```
    Expect results to include `"state": "Ok"`

    > To list all storage account configured to the web app.
    > ```
    > az webapp config storage-account list
    >

1. Open a remote connection to the web app. 

    ```shell
    az webapp create-remote-connection
    ```
     
    Expect a similar message below, and retrieve the port number.
    ```
    Verifying if app is running....
    App is running. Trying to establish tunnel connection...
    Opening tunnel on port: <port number>
    SSH is available { username: root, password: Docker! }
    Ctrl + C to close
    ```

1. From a separate terminal, start an SSH session to the container.

    ```shell
    ssh root@127.0.0.1 -p <port number>
    ```

    Enter a password of `Docker!`.

1. Confirm the shared storage in the web app from the SSH session.

    ```console
    :/home# cat /myshare/hello-from-cli.txt
    hello from az cli
    echo "hello from web app" > /myshare/hello-from-web-app.txt
    :/home# ls /myshare
    hello-from-cli.txt  hello-from-web-app.txt
    ```

1. From the local terminal, confirm the new file.

    ```shell
    az storage file list --account-name $storeaccname --account-key $storeacckey \
        --share-name $sharename \
        --query [].name --output tsv
    ```
    Expect the see both `hello-from-cli.txt` and `hello-from-web-app.txt`.

## **Clean Up**

{% include az-cli/999-cleanup.md %}

    >To detach the storage share from the web app.
    >```
    >az webapp config storage-account delete --custom-id $shareId
    >```

    >To delete the storage share from the storage account.
    >```
    >az storage share delete --name $sharename --account-name $storeaccname --account-key $storeacckey
    >```

    >To delete the storage account.
    >```
    >az storage account create --name $storeaccname
    >```

## **Further Reading**

- [Azure Storage Overview pricing](https://azure.microsoft.com/en-gb/pricing/details/storage/){:target="_blank"}
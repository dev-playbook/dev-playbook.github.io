---
title: Scaling Out Azure Web Apps (Manually)
index: 45
layout: post
date: 2020-11-19 19:00
categories: 
    - Azure CLI
    - Azure WebApps
permalink: azure-cli/webapps/scale-out-manually
tags: 
    - devops
    - scaling
    - scaling out
description: This tutorial shows how to manually configure an Azure Web App to load-balanced with multiple worker instances.
---
>tl;dr
```shell
# update app service plane to 2 worker instance
az appservice plan update -g {group name} \
        --name {appservice plan name} \
        --number-of-workers {instance count}
```

## **Introduction**

{{ page.description }} **Note that the process requires upgrading to the chargeable [Basic Service Plan for Linux](https://azure.microsoft.com/en-gb/pricing/details/app-service/linux/){:target="_blank"}**.

To complete the tutorial, you will need the following.

- bash terminal
- Azure CLI installed
- A personal Azure Account

## **Preperations**

1. Complete the _[introductory tutorial]({% link _posts/azure-cli/webapps/2020-11-15-introduction.md %})_ excluding Clean Up.

1. Confirm the app service plan has an F1 SKU
    ```shell
    planId=$(az webapp show --query appServicePlanId | sed -e s/\"//g)
    az appservice plan show --ids $planId --query sku
    ```
    Expect the following payload in return.
    ```json
    {
        "capabilities": null,
        "capacity": 1,
        "family": "F",
        "locations": null,
        "name": "F1",
        "size": "F1",
        "skuCapacity": null,
        "tier": "Free"
    }
    ```

1. Confirm the default arguments to `az` command for _group_ and _web_ are configured.
    ```shell
    az configure --list-defaults --output table
    ```

1. Ensure that variable $appname has the value of the web app's name.

    ```shell
    [[ -z "$appname" ]] && appname=$(az webapp show --query "name" --output tsv | sed -E "s/\r//g")
    ```

## **Scaling Out**

1. Test the current single-worker web app and view its server log.
    ```shell
    az webapp browse --log
    ```
    Refresh the page a couple of times, and expect the tail end of logs to include 'Hello World' messages. Ctrl-C to exit.

1. Upgrade the app service plan with 2 worker instances.

    ```shell
    planId=$(az webapp show --query appServicePlanId | sed -e s/\"//g)
    az appservice plan update --ids $planId --sku B1 --number-of-workers 2
    ```
    Expect the resulting payload to include the following in the <code>SKU</code> section confirming the _scaling-up_ to B1 and a _scaling-out_ to 2 worker instance capacity.
    ```json
    {
        "capabilities": null,
        "capacity": 2,
        "family": "B",
        "locations": null,
        "name": "B1",
        "size": "B1",
        "skuCapacity": null,
        "tier": "Basic"
    }
    ```
    We have scaled up to Basic tier B1 SKU as this is the minimum tier to scale out more instances.
    > Basic a is production-grade tier for low traffic requirements. It has the following features and limitations.
    > - Uses _dedicated virtual machines_ allowing scaling out to multiple instances.
    > - Limited to _manual scaling_.
    > - Allows for _customised domains_ and the use of _ssl certificates_
    > - _No deployment slots_ for staging environments.

1. Confirm that the site still works and stream the logs.

    ```shell
    az webapp browse --logs
    ```
    Note that the log pattern is different from the previous log tails. It is not showing events in the webserver. Refresh the web page a couple of times and note that 'Hello World' messages are not appearing at the tail end. 

    Instead, it is showing entries for starting docker containers. Ignoring duplicate entries, note that 2 containers were initialized with differing port mappings (<code>-p</code>) and names (<code>-name</code>).
    
    Also note the entry <code>'Logging is not enabled for this container'</code> and consequently, 'Hello World' messages are not captured. To enable this feature, follow the section _[Storing Web Server Logs in Logging]({% link _posts/azure-cli/webapps/2020-11-17-logging.md%}) tutorial_

## **Clean up**

1. Delete all resources created in the group, including the web app and app service.

    ```shell
    az group delete --yes
    ```

## **Further Reading**

- [App Service pricing for windows](https://azure.microsoft.com/en-gb/pricing/details/app-service/windows/){:target="_blank"}
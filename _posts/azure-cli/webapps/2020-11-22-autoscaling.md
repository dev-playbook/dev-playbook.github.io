---
title: Autoscaling Azure Web Apps
index: 50
layout: post
date: 2020-11-22 13:00
categories: 
    - Azure CLI
    - Azure WebApps
permalink: azure-cli/webapps/autoscaling
tags: 
    - devops
    - scaling
    - scaling out
    - autoscaling
description: This tutorial shows how to configure autoscaling for Azure Web App to allow load-balancing with multiple instances.
---
>tl;dr
>```shell
># create a monitor to the app service plan for autoscaling
>az monitor autoscale create \
>       --name {autoscale name} \
>       --resource {appservice plan name} \
>       --resource-type 'Microsoft.Web/serverfarms'  \
>       --count {default count} --min-count {min} --max-count {max} \
>       --email-administrator {true|false}
>
># add an autoscaling rule to the monitor
>az monitor autoscale rule create \
>       --autoscale-name {autoscale name} \
>       --profile-name default \
>       --condition {scale rule} \ # e.g "CpuPercentage >= 75 avg 10m"
>       --scale {in|out} {instance count}
>```

## **Introduction**

{{page.description}} **Note that the process requires use of the chargeable [Standard Service Plan for Linux](https://azure.microsoft.com/en-gb/pricing/details/app-service/linux/){:target="_blank"}**.

To complete the tutorial, you will need the following.

- bash terminal
- Azure CLI installed
- A personal Azure Account

## **Prepare**
{%include az-cli/005-login-account.md%}
{% include az-cli/010-create-resource-group.md %}

## **Create Autoscaling Web App**

{% include az-cli/020-create-app-service.md sku="S1"%}

    Standard is the minimum tier for autoscaling.

    Expect the resulting payload to include the following in the <code>SKU</code> section confirming the _scaling-up_ to S1 and a capacity of just 1 worker instance.
    ```json
    {
        "capabilities": null,
        "capacity": 1,
        "family": "S",
        "locations": null,
        "name": "S1",
        "size": "S1",
        "skuCapacity": null,
        "tier": "Standard"
    }
    ```

{% include az-cli/030-create-webapp-nodejs.md %}

1. Create an autoscale monitor for the app service plan that configures the instance capacities.

    ```shell
    autoscalename=webapp-demo-asplan-autoscale

    az monitor autoscale create \
        --name $autoscalename \
        --resource $planname \
        --resource-type 'Microsoft.Web/serverfarms'  \
        --count 1 --min-count 1 --max-count 2 \
        --email-administrator true \
        --verbose
    ```
    Expect results to confirm the creation of the autoscale monitor, with the _1 default, 1 minimum and 2 maximum capacities_ on the <code>default</code> entry in the <code>profiles</code> collection. 
    ```json
    "profiles": [
        {
            "capacity": {
                "default": "1",
                "maximum": "2",
                "minimum": "1"
            },
            "fixedDate": null,
            "name": "default",
            "recurrence": null,
            "rules": []
        }
    ]
    ```
    Note that the <code>--email-administrator</code> clause has been included. Consequently, you will receive a message to an email address registered on your subscription whenever the capacity has been raised or lowered.

    Finally, note the message <code>'Follow up with `az monitor autoscale rule create` to add scaling rules'</code>. This is to be done next.

1. Add autoscale rules to raise the instance count by 1 when Bytes Received 1-minute average goes over 9999, and lower the instance count by 1 when Bytes Received 2-minute average goes to zero respectively.

    ```shell
    az monitor autoscale rule create \
        --autoscale-name $autoscalename \
        --profile-name default \
        --condition "BytesReceived >= 10000 avg 1m" \
        --scale out 1

    az monitor autoscale rule create \
        --autoscale-name $autoscalename \
        --profile-name default \
        --condition "BytesReceived <= 0 avg 2m" \
        --scale in 1
    ```
    >Note the <code>BytesReceived</code> is the metric employed. To list all available metrics you can employ to monitor your app service plan, execute either of the following.
    > ```
    > az monitor metrics list-definitions --resource $planname \
    >       --resource-type 'Microsoft.Web/serverfarms' --output table
    >
    > az monitor metrics list-definitions --resource $planId --output table
    > ```

1. Review the autoscale rules from the configured monitor.

    ```shell
    az monitor autoscale show --name $autoscalename
    ```
    Expect a similar <code>profiles</code> section below.
    ```json
    "profiles": [
        {
            "capacity": {
                "default": "1",
                "maximum": "2",
                "minimum": "1"
            },
            "fixedDate": null,
            "name": "default",
            "recurrence": null,
            "rules": [
                {
                    "metricTrigger": {
                        "dimensions": [],
                        "dividePerInstance": false,
                        "metricName": "BytesReceived",
                        "metricNamespace": "",
                        "metricResourceUri": ".../Microsoft.Web/serverfarms/webapp-demo-asplan",
                        "operator": "GreaterThanOrEqual",
                        "statistic": "Average",
                        "threshold": 10000.0,
                        "timeAggregation": "Average",
                        "timeGrain": "0:01:00",
                        "timeWindow": "0:01:00"
                    },
                    "scaleAction": {
                        "cooldown": "0:05:00",
                        "direction": "Increase",
                        "type": "ChangeCount",
                        "value": "1"
                    }
                },
                {
                    "metricTrigger": {
                        "dimensions": [],
                        "dividePerInstance": false,
                        "metricName": "BytesReceived",
                        "metricNamespace": "",
                        "metricResourceUri": ".../Microsoft.Web/serverfarms/webapp-demo-asplan",
                        "operator": "LessThanOrEqual",
                        "statistic": "Average",
                        "threshold": 0.0,
                        "timeAggregation": "Average",
                        "timeGrain": "0:01:00",
                        "timeWindow": "0:02:00"
                    },
                    "scaleAction": {
                        "cooldown": "0:05:00",
                        "direction": "Decrease",
                        "type": "ChangeCount",
                        "value": "1"
                    }
                }
            ]
        }
    ]
    ```
    Note that cooldown defaults to <code>05:00</code> minutes, which is the time that elapse before the next scaling event occurs. This can be overridden by passing an argument to the <code>--cooldown</code> parameter.

1. Start a new command-line session and start traffic to the site.

    ```shell
    appname=$(az webapp show --query "name" | sed -e 's/["\r ]//g')

    for (( ; ; ))
    do 
        curl http://$appname.azurewebsites.net?foo=$RANDOM
        sleep 1
    done;
    ```
    This small script will request for the home page every second.

1. Wait for the web apps to scale out.

    ```shell
    az webapp log tail
    ```
    Wait for around 5 minutes and expect the log tails to say that a new docker container is created.

    Shut down the site traffic by pressing _Ctrl-C_.

    Wait for another 5 minutes. _DO NOT expect the log tails to say that a docker container was removed_.

1. Confirm autoscaling had occurred.

    ```shell
    az monitor activity-log list --output table \
            --caller Microsoft.Insights/autoscaleSettings
    ```
    Ignoring duplicate entries, expect 4 entries with the following descriptions.

    ```shell
    The autoscale operation to scale resource '{appsevice plan id}' from 2 instances count to 1 instances count completed successfully.
    The autoscale engine attempting to scale resource '{appsevice plan id}' from 2 instances count to 1 instances count.            
    The autoscale operation to scale resource '{appsevice plan id}' from 1 instances count to 2 instances count completed successfully.
    The autoscale engine attempting to scale resource '{appsevice plan id}' from 1 instances count to 2 instances count. 
    ```
    From the activity logs, you can see that the instance counts went from 1 to 2 and back to 1.

    Also, check your account email for notifications from Azure Monitor stating the capacity had been raised and lowered.

1. View the number of bytes received to the site

    ```shell
    az monitor metrics list --resource $planId --output table --metric BytesReceived
    ```
    Confirm the bytes received coincide with the autoscaling events.

## **Clean up**

{% include az-cli/999-cleanup.md %}
    >To delete the autoscaling.
    >```
    >az monitor autoscale delete --name $autoscalename
    >```
    >To scale down to the FREE tier
    >```
    >az appservice plan update --ids $planId --sku F1
    >```

## **Further Reading**

- [Azure Monitor overview](https://docs.microsoft.com/en-us/azure/azure-monitor/overview)
- [App Service pricing for windows](https://azure.microsoft.com/en-gb/pricing/details/app-service/windows/){:target="_blank"}
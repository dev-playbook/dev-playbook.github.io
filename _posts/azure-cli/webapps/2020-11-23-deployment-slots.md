---
title: Azure Web Apps and Deployment Slots
index: 50
layout: post
date: 2020-11-23 15:00
categories: 
    - Azure CLI
    - Azure WebApps
permalink: azure-cli/webapps/deployment-slots
tags: 
    - devops
    - deployment slots
description: Deploying web apps allows you the option to use separate deployment slots instead of just a singular  production environment. Slots, including production, can swap application content and configurations while maintaining their separate hostnames. 
---
>tl;dr
>```shell
># set application settings for both environment and slot
>az webapp config appsettings set -n {app name} -g {group name} \
>       --slot {slot name}
>       --settings {key}={value} \
>       --slot-settings {key}={value}
>
># create a slot for the web app
>az webapp deployment slot create -n {app name} -g {group name} \
>       --slot {slot name}
>
># preview the swap to production in staging
>az webapp deployment slot swap -n {app name} -g {group name} \
>       --slot {slot name} \
>       --action preview
>
># swap manually
>az webapp deployment slot swap -n {app name} -g {group name} \
>       --slot {slot name}
>
># auto swap
>az webapp deployment slot auto-swap -n {app name} -g {group name} \
>   --slot {slot name}
>```

## **Introduction**

{{page.description}} 

Deploying using slots has the following benefits:
+ You can validate app changes in staging before swapping with production.
+ You can eliminate downtime by ensuring a deployment warmed up before swapping it with production.
+ You can roll back your deployed production by swapping back to the preceding version.

This tutorial goes thru the process of allocating, deploying and swapping slots in Azure Web Apps.

Deployment Slots are only available with production-grade service plans tiers, including Standard, Premium and Isolated. **Note that this tutorial will be using the [Standard Service Plan for Linux](https://azure.microsoft.com/en-gb/pricing/details/app-service/linux/){:target="_blank"}**.

To complete the tutorial, you will need the following.

- bash terminal
- Azure CLI installed
- A personal Azure Account

## **Prepare**

1. Complete the _[Azure Local Git tutorial]({% link _posts/azure-cli/webapps/2020-11-17-local-git.md %})_ excluding Clean Up.

1. Confirm the default arguments to <code>az</code> command for _group_ and _web_ are configured.
    ```shell
    az configure --list-defaults --output table
    ```

1. Ensure that bash variables <code>appname</code> has the value of the web app's name.

    ```shell
    [[ -z "$appname" ]] && appname=$(az webapp show --query "name" | sed -e 's/["\r ]//g')
    ```
    
## **Production Slot**

Note that the environment where the site is running is considered to be the default or **production slot**.

{% include az-cli/022-upgrade-app-service.md sku="S1"%}

    Standard is minimum tier required for deployment slots.

1. Set the application settings _EnvironmentId_ and _DatabaseConnection_.

    ```shell
    az webapp config appsettings set \
        --settings EnvironmentId=Environment_1 \
        --slot-settings DatabaseConnection=production-db-connection \
        --verbose
    ```
    Expect the following results.
    ```json
    [
        {
            "name": "EnvironmentId",
            "slotSetting": false,
            "value": "Environment_1"
        },
        {
            "name": "DatabaseConnection",
            "slotSetting": true,
            "value": "production-db-connection"
        }
    ]
    ```
    Key value pairs on both <code>--settings</code> and <code>--slots-settings</code> are exposed to the application as environment variables. The difference is that values under <code>--settings</code> are exchanged during slot swaps, whilst values under <code>--slot-settings</code> stay on the slot during a swap.

    >You can confirm the app settings exists thru the <code>/api/settings</code> pages of Kudu Source Control Management.
    >```
    >xdg-open https://$appname.scm.azurewebsites.net/api/settings
    >```

1. Test the website and expect a header message _'Hello World from Version 2'_.

    ```shell
    az webapp browse
    ```
    From the resulting page, expect the following under ENVIRONMENT VARS
    ```
    DatabaseConnection: production-db-connection
    EnvironmentId: Environment_1
    ```

## **Staging Slot**

1. Create a deployment slot for the staging environment.

    ```shell
    staging=staging
    az webapp deployment slot create --name $appname --slot $staging --verbose
    ```
    Expect a result indicating the environment was successfully created.

    >Note the web app name in <code>--name</code> was not omitted as it does not pick up the web app name from az configure defaults.

    >To list all slots, excluding _production_
    >```
    >az webapp deployment slot list --name $appname --output table
    >```

1. Test the deployed environment from the slot and expect a placeholder site.

    ```shell
    az webapp browse --slot $staging
    ```

1. Set the application settings _EnvironmentId_ and _DatabaseConnection_ the staging slot.

    ```shell
    az webapp config appsettings set --slot $staging \
        --settings EnvironmentId=Environment_2 \
        --slot-settings DatabaseConnection=staging-db-connection \
        --verbose
    ```
    Expect the following results.
    ```
    [
        {
            "name": "EnvironmentId",
            "slotSetting": false,
            "value": "Environment_2"
        },
        {
            "name": "DatabaseConnection",
            "slotSetting": true,
            "value": "staging-db-connection"
        }
    ]
    ```
    >You can confirm the app settings exists for the staging slot thru the <code>/api/settings</code> pages of Kudu Source Control >Management.
    >```
    >xdg-open https://$appname-$staging.scm.azurewebsites.net/api/settings
    >```

## **Staging Version 3**

{% include az-cli/070-get-site-level-creds.md slot="staging" %}

1. From the <code>nodejs-env-request-vars</code> repository created in [Azure Local Git tutorial]({% link _posts/azure-cli/webapps/2020-11-17-local-git.md %}), detach the production's remote git repository and attach it to the staging's remote git repository.

    ```shell
    git remote remove origin
    
    repoUrl=https://$username:$password@$appname-$staging.scm.azurewebsites.net/$appname.git
    echo $repoUrl

    git remote add origin $repoUrl
    ```
    
    Note the site-credentials are included in the repository Url. Excluding the username and password from the Url will result in the command line asking for your credentials.

    >The remote repository is provided by the [Kudu Source Control Manager](https://azure.microsoft.com/en-gb/resources/videos/what-is-kudu-with-david-ebbo/).

1. Execute the following to change the header message of the NodeJS app to **Version 3**.

    ```shell
    (cat ./app.js) | sed -e 's/Version ./Version 3/g' > app.js
    ```

1. Commit and push the changes to the staging slot's remote git repository.

    ```shell
    git checkout master
    git add ./app.js
    git commit -m 'updated to Version 3'

    git push --set-upstream origin master
    ```
    Expect messages indicating a successful build and deployment.

1. Test the website in staging and expect a header message _'Hello World from Version 3'_.

    ```shell
    az webapp browse --slot $staging
    ```
    From the resulting page, expect the following under ENVIRONMENT VARS
    ```
    DatabaseConnection: staging-db-connection
    EnvironmentId: Environment_2
    ```

## **Previewing Version 3 in Staging**

1. Preview the production deployment in staging.

    ```shell
    az webapp deployment slot swap --name $appname --slot $staging --action preview --verbose
    ```
    Note that <code>--target-slot</code> is not specified as it defaults to <code>production</code>.

1.  Test the web app in production and staging.

    ```shell
    az webapp browse 

    az webapp browse --slot $staging
    ```

    Expect the following results (you may have to wait for a minute to see the expected result).

    | | **Production** | **Staging** |
    | _Header Message_ | ... from Version 2 | ... from Version 3 |
    | _EnvironmentId_ | Environment_1 | Environment_2 |
    | _DatabaseConnection_ | production-db-connection | production-db-connection |

    Note that staging has maintained the same environment id (_Environment_2_) while using the database connection setting from the production slot. So the intention is to allow the user testing within the staging environment of the staged content and production settings.

## **Deploying Version 3 to Production Manually**

1. Swap staging to production.

    ```shell
    az webapp deployment slot swap --name $appname --slot $staging --verbose
    ```
    >Note the web app name in <code>--name</code> was not omitted as it does not pick up the web app name from az configure defaults.

1. Test the web app and production and staging.

    ```shell
    az webapp browse

    az webapp browse --slot $staging
    ```
    Expect the following results (you may have to wait for a minute to see the expected result).

    | | **Production** | **Staging** |
    | _Header Message_ | ... from Version 3 | ... from Version 2 |
    | _EnvironmentId_ | Environment_2 | Environment_1 |
    | _DatabaseConnection_ | production-db-connection | staging-db-connection |

    Note that the header messages and environment ids values have swapped between slots but the database connection values are maintained.

## **Deploying Version 4 to Production with Autoswap**

1. Set staging to auto-swap with the production slot.

    ```shell
    az webapp deployment slot auto-swap --name $appname --slot $staging --verbose
    ```
    Expect resulting payload to include the following, indicating an auto-swap to production.
    ```
    "autoSwapSlotName": "production",
    ```
    >Note the web app name in <code>--name</code> was not omitted as it does not pick up the web app name from az configure defaults.

1. Execute the following to change the header message of the NodeJS app to **Version 4**.

    ```shell
    (cat ./app.js) | sed -e 's/Version ./Version 4/g' > app.js
    ```

1. Commit and push the changes to the staging slot's remote git repository.

    ```shell
    git checkout master
    git add ./app.js
    git commit -m 'updated to Version 4'
    git push
    ```
    Expect messages indicating a successful build and deployment. 
    
    Also expect a _Requesting auto swap to 'production' slot... successful_ message, indicating that an auto-swap has commenced.
    
    You may have to wait for a few minutes for the swap to complete before continuing.

1. Test the web app and production and staging.

    ```shell
    az webapp browse

    az webapp browse --slot $staging
    ```
    Expect the following results (you may have to wait for a minute to see the expected result).

    | | **Production** | **Staging** |
    | _Header Message_ | ... from Version 4 | ... from Version 3 |
    | _EnvironmentId_ | Environment_1 | Environment_2 |
    | _DatabaseConnection_ | production-db-connection | staging-db-connection |

    Note that the environment Ids values have swapped again but the database connection values are maintained, and the production is now Version 4.

## **Activity log**

1. Extract the logged activities by <code>SlotSwapJobProcessor</code> and save it to file.

    ```shell
    az monitor activity-log list --caller SlotSwapJobProcessor --output table > activity-log.txt
    ```

1. Open file <code>activity-log.txt</code> and expect the following entries logged throughout this tutorial.

    ```
    Finished swapping site. New state is (Slot: 'staging', DeploymentId:'{preceeding-deployment}'), (Slot: 'Production', DeploymentId:'{succeeding-deployment}')'.
    Finished warming of site with deploymentId '{succeeding-deployment}'
    Initial state for slot swap operation is (Source slot: 'staging', DeploymentId:'{succeeding-deployment}') (TargetSlot: 'Production', DeploymentId:'{preceeding-deployment}')'.
    Applied configuration settings from slot 'Production' to a site with deployment id '{succeeding-deployment}' in slot 'staging'
    ```

    Read from bottom to top, these log entries are expected from successful swaps and auto-swaps. For preview swaps, only the first\bottom entry is expected.
    
    The process starts by applying the values in <code>--settings</code> from production to the _succeeding deployment_ in staging.

    From '<code>Initial state</code>', it reports that the _succeeding deployment_ is in staging, while the _preceeding deployment_ is in production.
    
    The process then '<code>Finished warming</code>' the _succeeding deployment_ and then the swap occurs.

    When concluded, it reports '<code>Finished swapping site</code>' and the _succeeding deployment_ is in production and the _preceeding deployment_ is in staging.

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

- [Create an App Service app and deploy code to a staging environment using Azure CLI](https://docs.microsoft.com/en-us/azure/app-service/scripts/cli-deploy-staging-environment)
- [App Service pricing for windows](https://azure.microsoft.com/en-gb/pricing/details/app-service/windows/){:target="_blank"}
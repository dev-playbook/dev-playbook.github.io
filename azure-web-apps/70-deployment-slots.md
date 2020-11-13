# Deployment slots

Deploying web apps allows the option you to use separate deployment slots instead of a singular  production environment. Slots, including production, can swap application content and configurations while maintaining their own host names.

Deploying using slots has the following benefits:

+ You can validate app changes in staging before swapping with production.

+ You can eliminate downtime by ensuring a deployment warmed up before swapping it with production.

+ You can roll back your deployed production by swapping back to the preceeding version.

Deployment Slots are only available with production-grade service plans tiers, including Standard, Premium and Isolated.

This tutorial goes thru the process of allocating, deploying and swapping slots in Azure Web Apps.

## Create service application

1. Open PowerShell and navigate to a working folder.

1. Login to your Azure account. 

        az login

1. Create a resource group and default subsequent commands to the group and location West US

        $rg = 'webapp-demo-rg'

        $location = 'westus'

        az group create --name $rg --location $location

        az configure --defaults group=$rg location=$location

1. Create an Azure App Service Plan, with standard SKU and Linux platform

        $planname = "webapp-demo-asplan"

        az appservice plan create --name $planname --sku S1 --is-linux

## Create the production and staging slots

1. Create the web app using the new app service plan, with a unique name and runtime version of node.

        $appname = "webapp-demo-app-$(Get-Random)"

        az webapp create --name $appname --plan $planname --% --runtime "node|12-lts"

    The web app is considered as the default / production slot.

1. Create a staging slot for deployment.

        $staging = 'staging'

        az webapp deployment slot create --name $appname --slot $staging

1. Test placeholder websites deployed to both production and staging.

        az webapp browse --name $appname

        az webapp browse --name $appname --slot $staging

1. Set the application settings _EnvironmentId_ and _DatabaseConnection_ for both production and staging.

        az webapp config appsettings set --name $appname `
            --settings EnvironmentId=Environment_1 `
            --% --slot-settings DatabaseConnection={production-db-connection}

        az webapp config appsettings set --name $appname --slot $staging `
            --settings EnvironmentId=Environment_2 `
            --% --slot-settings DatabaseConnection={staging-db-connection}

    Key value pairs on both <code>--settings</code> and <code>--slots-settings</code> are exposed to the application as environment variables. The difference is that values under <code>--settings</code> are exchanged during slot swaps, whilst values under <code>--slot-settings</code> stay on the slot during a swap.

    You can confirm the app settings exists thru the <code>/api/settings</code> pages of Kudu Source Control Management.
        
        Start-Process https://$appname.scm.azurewebsites.net/api/settings
        
        Start-Process https://$appname-$staging.scm.azurewebsites.net/api/settings

## Create a NodeJS web app

1. Set the deployment source of staging to local git

        az webapp deployment source config-local-git --name $appname --slot $staging

1. Create a working folder for NodeJS website.

        mkdir www-app

        cd www-app

1. Create <code>package.json</code> with the following content.

        {
            "scripts": {
                "start": "node app.js"
            }
        }

1. Create <code>app.js</code> with the following content. 

        const http = require('http');

        process.env.envId = process.env.envId || "Development"

        process.env.db = process.env.db || "{local-db-connection}"

        const server = http.createServer((request, response) => {
            response.writeHead(200, {"Content-Type": "text/plain"});
            response.end("Version 1: Hello From "+ process.env.envId + ", dbConnection = " + process.env.db);
        });

        const port = process.env.PORT || 1337;

        server.listen(port);

1. Start the NodeJs app locally and test by navigating to http://localhost:1337 with a browser.

        npm start

    Expect the following output on the page

        Version 1: Hello From Development, dbConnection = {local-db-connection}

## Setup local git deployment for staging 

1. Setup a local git repository

        git init

        git add -A

        git config user.name 'foo-git-user'

        git config user.email 'foo-git-user@bar.qux'

        git commit -m 'initial commit'

1. Link the local repository to remote repository of staging managed by Kudu.

        $remoteUrl = "https://$appname-$staging.scm.azurewebsites.net/$appname.git"

        git remote add origin $remoteUrl

## Deploy app to staging

1. Get site-credential details <code>publishingUserName</code> and <code>publishingPassword</code> for deployment to staging.

        az webapp deployment list-publishing-credentials --name $appname --slot $staging

1. Push to the remote git repository, entering the extracted credentials.

        git config credential.helper store

        git push --set-upstream origin master

    Note the output should return successful build and deployment messages.

    You can view the deployment logs by executing the following

        az webapp log deployment show --name $appname --slot $staging --output table 

1. Test the web app in staging.

        az webapp browse --name $appname --slot $staging

    Expect the following output (you may have to wait for a minute)

        Version 1:  Hello From Environment_2, dbConnection = { staging-db-connection }

## Preview deployment in staging

1. Preview the production deployment in staging

        az webapp deployment slot swap --name $appname --slot $staging --action preview --verbose

    Note that <code>--target-slot</code> defaults to <code>production</code>.

    Test the web app in staging.

        az webapp browse --name $appname --slot $staging

    Expect the following output (you may have to wait for a minute to see the expected result).

        Version 1: Hello From Environment_2, dbConnection = {production-db-connection}

    Note that staging has maintained the same environment id (_Environment_2_) while using the database connection setting from the production slot.

    Test the default web app and expect it unchanged.

        az webapp browse --name $appname

1. Reset the app settings of staging back to its original values.

        az webapp deployment slot swap --name $appname --slot $staging --action reset --verbose

1. Extract the activity log entries for the swaps

        az monitor activity-log list --caller SlotSwapJobProcessor --output table > activity-log.txt

## Swap manually

1. Swap staging to production.

        az webapp deployment slot swap --name $appname --slot $staging --verbose

    Test the default web app.

        az webapp browse --name $appname

    Expect the following output.

        Version 1: Hello From Environment_2, dbConnection = {production-db-connection}

    Note that production has inherited the environment id from staging and has maintained the production database connection after the swap.

    Test the staging web app and expect the placeholder site taken from the production slot.

        az webapp browse --name $appname --slot $staging

## Swap automatically

1. Set staging to auto-swap with the production slot.

        az webapp deployment slot auto-swap --name $appname --slot $staging --verbose

1. Update the NodeJs app's output, run locally and test by navigating to http://localhost:1337 with a browser.

        cp .\app.js .\app.js.old

        (cat .\app.js.old) -replace 'Version 1', 'Version 2' | Out-File .\app.js -Encoding UTF8

        npm start

    Commit changes and push to Kudu`s local git repository.

        git add .\app.js
            
        git commit -m 'updated to Version 2'

        git push

    Note the output should return a successful build and deployment by Kudu. 
    
    Also expect a _Requesting auto swap to 'production' slot... successful_ message, indicating that an auto-swap has commenced.
    
    You may have to wait for a few minutes for the swap to complete before continuing.

1. Test the web app in staging.

        az webapp browse --name $appname --slot $staging

    If you get this result, then the app has been deployed to staging but is currently being swapped.

        Version 2: Hello From Environment_1, dbConnection = {staging-db-connection}

    Note the message is prefixed with _Version 2_, indicating a successful build and deployment.

    Wait for a few minutes, refresh the page and expect the following output.

        Version 1: Hello From Environment_2, dbConnection = {staging-db-connection}

    Note the message is prefixed with _Version 1_, indicating a successful swap.

1. Test the web app in production.

        az webapp browse --name $appname 

    Expect the following output

        Version 2: Hello From Environment_1, dbConnection = { production-db-connection }

    Note the message is prefixed with _Version 2_, indicating a successful auto-swap with staging.

## Activity log

1. Extract the logged activities of the <code>SlotSwapJobProcessor</code> and save it to file.

    az monitor activity-log list --caller SlotSwapJobProcessor --output table > activity-log.txt

1. Open the file and expect the following entries logged throughout this tutorial.

        Finished swapping site. New state is (Slot: 'staging', DeploymentId:'{preceeding-deployment}'), (Slot: 'Production', DeploymentId:'{succeeding-deployment}')'.
        Finished warming of site with deploymentId '{succeeding-deployment}'
        Initial state for slot swap operation is (Source slot: 'staging', DeploymentId:'{succeeding-deployment}') (TargetSlot: 'Production', DeploymentId:'{preceeding-deployment}')'.
        Applied configuration settings from slot 'Production' to a site with deployment id '{succeeding-deployment}' in slot 'staging'

    This log set, read from bottom to top, would be typical of a successful manual swap and auto-swap. For preview swaps, only the first entry is expected.
    
    The process starts by applying the values in <code>--settings</code> from production to the _succeeding deployment_ in staging.

    Prior to the swap, it reports that the _succeeding deployment_ is in staging, while the _preceeding deployment_ is in production.
    
    The process then warms the _succeeding deployment_ then the swap occurs.

    When concluded, it reports that the _succeeding deployment_ is in production and the _preceeding deployment_ is in staging.

## Clean up

1. Execute the following to delete individual slots.

    az webapp deployment slot delete --name $appname --slot $staging --verbose

1. Delete all other resources created in the group.

        az group delete --yes

Other Information:

- Although key value pairs in <code>--settings</code> are exchanged during swaps, they can be overriden afterwards by calling <code>az webapp config appsettings set</code>.

- A swap to a target slot that has an auto swap to another slot will not trigger the auto swap. For example, given you have _pre-production_ slot auto-swaps to _production_, a manual swap from _staging_ to _pre-production_ will not trigger an auto-swap from _pre-production_ to _production_.

References:

- [Deploy staging slots](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots)

- [az webapp deployment slot](https://docs.microsoft.com/en-us/cli/azure/webapp/deployment/slot?view=azure-cli-latest)

- [az webapp config appsettings](https://docs.microsoft.com/en-us/cli/azure/webapp/config/appsettings?view=azure-cli-latest)

- [az monitor activity-log](https://docs.microsoft.com/en-us/cli/azure/monitor/activity-log?view=azure-cli-latest)

- [az monitor activity-log](https://docs.microsoft.com/en-us/cli/azure/monitor/activity-log?view=azure-cli-latest#az_monitor_activity_log_list_categories)
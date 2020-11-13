# Deploy NodeJS application from GitHub

- [ ] Create a resource group and default subsequent commands to group and location West US

        $rg = 'webapp-demo-rg'

        $location = 'westus'

        az group create --name $rg --location $location

        az configure --defaults group=$rg location=$location

- [ ] Create an Azure App Service Plan with FREE sku in the Linux platform
 
        $planname = 'webapp-demo-asplan'

        az appservice plan create --name $planname --sku FREE --is-linux

- [ ] Create the web app using the new app service plan, with a unique name and running a version of node

        $appname = "webapp-demo-app-$(Get-Random)"

        az webapp create --name $appname --plan $planname --% --runtime "node|12-lts"

- [ ] Test the new web app by navigating to the placeholder website

        az webapp browse --name $appname

    Alternatively, get the default host name and use the value to navigate to the site in a browser.

        az webapp show --name $appname --query "defaultHostName" --out tsv

- [ ] Deploy the source code from the git repository and test the resulting site.

        $repourl = "https://github.com/Azure-Samples/app-service-web-nodejs-get-started.git"

        az webapp deployment source config --name $appname `
            --repo-url $repourl --branch master `
            --manual-integration
            
        az webapp browse --name $appname

    Note the deployment is set to <code>--manual-integration</code>, meaning that code changes from source will not trigger a build of the web app. To enable this feature, execute the following:

        az webapp deployment source sync -n $appname

    To get the details of the web app deployment, simple execute the following.

        az webapp deployment source show --name $appname

- [ ] Test the deployed web app

        az webapp browse --name $appname

- [ ] Clean up by delete resources created in the default group

        az group delete --yes
---
title: Introduction to Azure Web Apps
---

Azure Web Apps is a platform to build an application in the cloud without the need to deploy, configure and maintain virtual machines. This introduction shows how to

- Create a Web App using a free tier plan
- Create its pre-requisites
- Deploy a simple node js application straight from GitHub
- Introduce Kudu Source Control Manager

To complete the tutorial, you will need the following.

- bash terminal
- Azure CLI installed
- A personal Azure Account

#### Pre-requisites

1. Create a resource group in West UK where the web app will be deployed.

        rg='webapp-demo-rg'
        location='ukwest'
        az group create --name $rg --location $location --verbose

    To use an alternative location, use the command below to list all available locations

        az account list-locations | grep -E "name" | sed 's/name//g' | sed 's/[ \",\:]//g'

    To confirm the existence of the group, check from a list the existing resource groups.

        az group list --output table

1. Configure the Azure CLI to use default arguments to allow brevity to subsequent commands
        
        az configure --defaults group=$rg location=$location

     From here on, subsequent commands will not need to specify arguments for resource group and location.

#### Creation

1. Create an Azure App Service Plan with FREE pricing tier in the Linux platform
 
        planname='webapp-demo-asplan'
        az appservice plan create --name $planname --sku FREE --is-linux --verbose

    The FREE SKU (Stock Keeping Unit) has the following limitations.

    - Uses _shared infrastructure_ with web apps from other accounts.
    - _No deployment slots_ for a staging environment.
    - _No custom domains_ so only {appname}.azurewebsite.net is possible.
    - _No scaling out_ to multiple instances to allow load balancing.

1. Create a web app using the service plan with a unique name and running the version of NodeJs.

        appname="webapp-demo-app-$RANDOM"
        az webapp create --name $appname --plan $planname --runtime "node|12-lts" --verbose

    To confirm its creation, check from a list existing web app

        az webapp list --output table

1. Configure the Azure CLI to use default argument to allow brevity to subsequent commands.
        
        az configure --defaults web=$appname
        
     From here on, subsequent commands will not need to specify arguments for the webapp name.

1. Open the new webapp and expect a placeholder page.

        az webapp browse

#### Deployment

1. Configure the source of the deployment from a GitHub repository.

        repourl="https://github.com/dev-playbook/nodejs-env-request-vars.git"
        az webapp deployment source config --repo-url $repourl --branch main --manual-integration --verbose

    The deployment is sourced from the <code>main</code> branch from a GitHub repository. The <code>--manual-integration</code> specifies no continuous deployment. Source changes can be deployed by calling the following.

        az webapp deployment source sync --verbose

    Expect an output similar to below after a successful deployment, specifying the details of the deployment.

        {
            "branch": "main",
            "deploymentRollbackEnabled": false,
            "id": "/subscriptions/{subscription-id}/resourceGroups/webapp-demo-rg/providers/Microsoft.Web/sites/webapp-demo-app-_random_/sourcecontrols/web",
            "isManualIntegration": true,
            "isMercurial": false,
            "kind": null,
            "location": "UK West",
            "name": "webapp-demo-app-_random_",
            "repoUrl": "https://github.com/dev-playbook/nodejs-env-request-vars.git",
            "resourceGroup": "webapp-demo-rg",
            "type": "Microsoft.Web/sites/sourcecontrols"
        }

    The same details can be retrieved as follows.

        az webapp deployment source show

#### Testing

1. Open the new site. 

        az webapp browse

    The NodeJs app exposes the environment variables and the HTTP request.

1. Output the log stream with either of the following options.

    - Call a CLI command to output the log stream.

            az webapp log tail

    - Browse the web app with log streaming.

            az webapp browse --logs

    - Navigate to the log stream from the SCM portal.

            xdg-open https://$appname.scm.azurewebsites.net/api/logstream

    Refresh the page and expect INFO trace messages from the log stream.

1. Open Kudu portal

        xdg-open https://$appname.scm.azurewebsites.net

    Kudu is the Source Control Manager integrated to Azure Web Apps. It automates deployments and provides tools to manage the web app such as access to settings, logs, files, secure shell, and so on.

1. Navigate to the Environment page

        xdg-open https://$appname.scm.azurewebsites.net/Env

    From here you can see all the environment settings required by the site, including Environment Variables. Key to note are as follows:

    - <code>WEBSITE_SITE_NAME</code> - The name of the site.
    - <code>WEBSITE_SKU</code> - The sku of the site (Possible values: Free, Shared, Basic, Standard).
    - <code>WEBSITE_COMPUTE_MODE</code> - Specifies whether website is on a dedicated or shared VM/s (Possible values: Shared , Dedicated).
    - <code>WEBSITE_HOSTNAME</code> - The Azure Website's primary host name for the site (For example: site.azurewebsites.net). Note     - that custom hostnames are not accounted for here.
    - <code>WEBSITE_INSTANCE_ID</code> - The id representing the VM that the site is running on (If site runs on multiple instances, each instance will have a different id).
    - <code>WEBSITE_NODE_DEFAULT_VERSION</code> - The default node version this website is using.
    - <code>WEBSOCKET_CONCURRENT_REQUEST_LIMIT</code> - The limit for websocket's concurrent requests.
    - <code>WEBSITE_COUNTERS_ALL</code> - (Windows only) all perf counters (ASPNET, APP and CLR) in JSON format. You can access, specific one such as ASPNET by <code>WEBSITE_COUNTERS_ASPNET</code>.

#### Clean up

1. Delete all resources created in the group, including the web app and app service.

        az group delete --yes

    To delete just the web app and the app service, use the command below.

        az webapp delete

#### References

- [GitHub: node-js-env-reqest-var](https://github.com/dev-playbook/nodejs-env-request-vars)
- [What is Kudu?](https://azure.microsoft.com/en-gb/resources/videos/what-is-kudu-with-david-ebbo/)
- [Azure CLI configuration](https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration)
- [App Service pricing](https://azure.microsoft.com/en-gb/pricing/details/app-service/windows/)

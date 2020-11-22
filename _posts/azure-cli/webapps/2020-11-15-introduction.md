---
title: Hello Azure Web Apps!
index: 10
layout: post
date: 2020-11-15 15:23
categories: 
    - Azure CLI
    - Azure WebApps
permalink: azure-cli/webapps/introduction
tags:
    - devops
    - paas
---

Azure Web Apps is a platform to build an application in the cloud without the need to deploy, configure and maintain virtual machines. This introduction shows how to...

- Create a web app with a free tier plan
- Create its pre-requisites
- Deploy a simple node js application sourced from a remote git repository 
- Introduce Kudu Source Control Manager

To complete the tutorial, you will need the following.

- bash terminal
- Azure CLI installed
- A personal Azure Account

## **Preperations**

1. Ensure that you are logged in to your Azure Account

    ```shell
    az account show
    # if not, login
    az login
    ```

1. Create a resource group in West UK where the web app will be deployed.

    ```shell
    rg='webapp-demo-rg'
    location='ukwest'
    az group create --name $rg --location $location --verbose
    ```
    Results should include details of the new group including allocated id and _provising state_ as _Succeeded_.
    
    > To recall the details of the resource group.
    > ```
    > az group show --name $rg
    > ```

    > To list all available locations to find alternatives.
    > ```
    > az account list-locations --output table
    > ```
    
    > To list existing resource groups.
    > ```
    > az group list --output table
    > ```

1. Configure the Azure CLI to use default arguments and confirm.
    
    ```shell
    az configure --defaults group=$rg location=$location
    az configure --list-defaults --output table
    ```
    The configured defaults should include values for _group_ and _location_. From here on, subsequent <code>az</code> commands will omit arguments for <code>--resource-group</code> and <code>--location</code>.

## **App Creation**

1. Create an Azure App Service Plan with FREE pricing tier in the Linux platform

    ```shell
    planname='webapp-demo-asplan'
    az appservice plan create --name $planname --sku FREE --is-linux --verbose
    ```
    Results should include details of the new service plan, including its Id, SKU details and provisioning state as _Succeeded_.

    > To create a service plan with the Windows platform, exclude <code>--is-linux</code>.

    > To recall the details of the plan.
    > ```
    > az appservice plan show --name $planname
    > ```

    > The FREE SKU (Stock Keeping Unit) has the following limitations.
    > - _Shares virtual machines_ with web apps from other accounts.
    > - _No deployment slots_ for a staging environment.
    > - _No custom domains_ so only {appname}.azurewebsite.net is possible.
    > - _No scaling out_ to multiple instances to allow load balancing.


1. Create a web app, with arguments including service plan, unique name and NodeJs runtime.
    
    ```shell
    appname="webapp-demo-app-$RANDOM"
    az webapp create --name $appname --plan $planname --runtime "node|12-lts" --verbose
    ```
    Results should include details of the new web app.

    > To recall the details of the web app.
    > ```
    > az webapp show --name $appname
    > ```

    > To list all available runtimes to find alternatives.
    > ```
    > az webapp list-runtimes
    > ```

    > To list all existing web app
    > ```
    > az webapp list --output table
    > ```

1. Add the app name as a default argument to Azure CLI and confirm.
    
    ```shell
    az configure --defaults web=$appname
    az configure --list-defaults --output table
    ```
    The configured defaults should include a value for _web_. From here on, subsequent <code>az</code> commands will omit arguments for <code>--resource-group</code>, <code>--location</code> and <code>--name</code> (of web app).

1. Open the web app and expect a placeholder page.

    ```shell
    az webapp browse
    ```

## **Source Deployment**

1. Configure the source of the deployment to the _main_ branch of a GitHub repository.

    ```shell
    repourl="https://github.com/dev-playbook/nodejs-env-request-vars.git"
    az webapp deployment source config --repo-url $repourl --branch main --manual-integration --verbose
    ```

    The source contains a small NodeJs application. The results should include details of the deployment source, including the repository Url and branch name.
    
    > To recall details of the deployment source configuration.
    > ```
    > az webapp deployment source show
    > ```

    The <code>--manual-integration</code> specifies no continuous deployment of source changes as this requires further setup and is out of scope.

## **Testing**

1. Open the site with the deployed source and stream the server logs.

    ```shell
    az webapp browse --log
    ```

    Expect a page with a _Hello World_ message and a list of key-value pairs from the environment variables and the HTTP request.

    Expect the stream to return a trail of the same _Hello World_ message.

1. Refresh the browser and expect INFO trace messages from the log stream.

    > Alternatively, you can stream the server logs as follows.
    > ```
    > az webapp log tail
    > ```
    > You can also view the log stream from the Kudu SCM portal.
    > ```
    > xdg-open https://$appname.scm.azurewebsites.net/api/logstream
    > ```

1. Open Kudu portal

    ```shell
    xdg-open https://$appname.scm.azurewebsites.net
    ```

    Kudu is the Source Control Manager integrated to Web Apps. It automates deployments and provides tools to manage the site such as access to settings, logs, files, secure shell, and so on.

1. Navigate to the Environment page

    ```shell
    xdg-open https://$appname.scm.azurewebsites.net/Env
    ```

    From here you can see all the environment settings accessible by the site, including Environment Variables. Key to note are as follows:

    - <code>WEBSITE_SITE_NAME</code> - The name of the site.
    - <code>WEBSITE_SKU</code> - The sku of the site (Possible values: Free, Shared, Basic, Standard).
    - <code>WEBSITE_COMPUTE_MODE</code> - Specifies whether website is on a dedicated or shared VM/s (Possible values: Shared , Dedicated).
    - <code>WEBSITE_HOSTNAME</code> - The Azure Website's primary host name for the site (For example: site.azurewebsites.net). Note     - that custom hostnames are not accounted for here.
    - <code>WEBSITE_INSTANCE_ID</code> - The id representing the instance that the site is running on (If the site runs on multiple instances, each instance will have a different id).
    - <code>WEBSITE_NODE_DEFAULT_VERSION</code> - The default node version this website is using.
    - <code>WEBSOCKET_CONCURRENT_REQUEST_LIMIT</code> - The limit for websocket's concurrent requests.
    - <code>WEBSITE_COUNTERS_ALL</code> - (Windows only) all perf counters (ASPNET, APP and CLR) in JSON format. You can access, specific one such as ASPNET by <code>WEBSITE_COUNTERS_ASPNET</code>.

## **Clean up**

1. Delete all resources created in the group, including the web app and app service.

    ```shell
    az group delete --yes
    ```

    > To delete just the web app and the app service.
    > ```
    > az webapp delete
    > ```

## **Further Reading**

- [What is Kudu?](https://azure.microsoft.com/en-gb/resources/videos/what-is-kudu-with-david-ebbo/){:target="_blank"}
- [Azure CLI configuration](https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration){:target="_blank"}
- [App Service pricing for Windows](https://azure.microsoft.com/en-gb/pricing/details/app-service/windows/){:target="_blank"}
- [App Service pricing for Linux](https://azure.microsoft.com/en-gb/pricing/details/app-service/windows/){:target="_blank"}

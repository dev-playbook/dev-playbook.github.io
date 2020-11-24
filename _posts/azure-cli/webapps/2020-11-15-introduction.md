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
description: Azure Web Apps is a platform to build an application in the cloud without the need to deploy, configure and maintain virtual machines. This introduction shows how to deploy a web app with a free tier plan, create the necessary resource group and app service plan, deploy a simple node js application sourced from a remote git repository, and introduce Kudu Source Control Manager.
---

## **Introduction**

{{page.description}}

{%include az-cli/000-prerequisites.md%}

## **Prepare**
{%include az-cli/005-login-account.md%}
{% include az-cli/010-create-resource-group.md %}
    
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

## **Create Web App**

{% include az-cli/020-create-app-service.md sku="F1" %}

    > To create a service plan with the Windows platform, exclude <code>--is-linux</code>.

    > To recall the details of the plan.
    > ```
    > az appservice plan show --name $planname
    > ```

{% include az-cli/030-create-webapp-nodejs.md%}

    > To recall the details of the web app.
    > ```
    > az webapp show --name $appname
    > ```

    > To list all available runtimes and find alternatives.
    > ```
    > az webapp list-runtimes
    > ```

    > To list all existing web app
    > ```
    > az webapp list --output table
    > ```

{% include az-cli/040-browse-webapp.md %}

    Expect to see a placeholder page for NodeJS apps.

## **Deploy Source**

1. Configure the source of the deployment to the _main_ branch of a GitHub repository.

    ```shell
    repourl="https://github.com/dev-playbook/nodejs-env-request-vars.git"
    az webapp deployment source config --repo-url $repourl --branch main --manual-integration --verbose
    ```

    The source contains a small NodeJs application. The results should include details of the deployment source, including the value of <code>repourl</code> as the repository Url and <code>main</code> as the branch name.
    
    > To recall details of the deployment source configuration.
    > ```
    > az webapp deployment source show
    > ```

    The <code>--manual-integration</code> specifies no continuous deployment of source changes as this requires further setup and is out of scope.

## **Test**

{% include az-cli/041-browse-webapp-stream-logs.md %}

    Expect a page with a _Hello World_ message and a list of key-value pairs from the environment variables and the HTTP request.

    Also expect the stream to return INFO traces of the same _Hello World_ message. Refresh the browser a couple of times to see the repeated traces.

    > Alternatively, you can stream the server logs as follows.
    > ```
    > az webapp log tail
    > ```
    > You can also view the log stream from the Kudu SCM portal.
    > ```
    > xdg-open https://$appname.scm.azurewebsites.net/api/logstream
    > ```

{% include az-cli/050-browse-kudu.md %}

    Kudu is the Source Control Manager integrated to Azure Web Apps. It automates deployments and provides features such as access to site settings, logs, file access, secure shell, remote git repository and so on.

1. Navigate to the Environment page in Kudu.

    ```shell
    xdg-open https://$appname.scm.azurewebsites.net/Env
    ```

    From here you can see all the environment settings accessible by the site, including Environment Variables. Keys-Values to note are as follows:

    - <code>WEBSITE_SITE_NAME</code> - The name of the site.
    - <code>WEBSITE_SKU</code> - The sku of the site (Possible values: Free, Shared, Basic, Standard).
    - <code>WEBSITE_COMPUTE_MODE</code> - Specifies whether website is on a dedicated or shared VM/s (Possible values: Shared , Dedicated).
    - <code>WEBSITE_HOSTNAME</code> - The Azure Website's primary host name for the site (For example: site.azurewebsites.net). Note     - that custom hostnames are not accounted for here.
    - <code>WEBSITE_INSTANCE_ID</code> - The id representing the instance that the site is running on (If the site runs on multiple instances, each instance will have a different id).
    - <code>WEBSITE_NODE_DEFAULT_VERSION</code> - The default node version this website is using.
    - <code>WEBSOCKET_CONCURRENT_REQUEST_LIMIT</code> - The limit for websocket's concurrent requests.
    - <code>WEBSITE_COUNTERS_ALL</code> - (Windows only) all perf counters (ASPNET, APP and CLR) in JSON format. You can access, specific one such as ASPNET by <code>WEBSITE_COUNTERS_ASPNET</code>.

## **Clean up**

{% include az-cli/999-cleanup.md%}

## **Further Reading**

- [What is Kudu?](https://azure.microsoft.com/en-gb/resources/videos/what-is-kudu-with-david-ebbo/){:target="_blank"}
- [Azure CLI configuration](https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration){:target="_blank"}
- [App Service pricing for Windows](https://azure.microsoft.com/en-gb/pricing/details/app-service/windows/){:target="_blank"}
- [App Service pricing for Linux](https://azure.microsoft.com/en-gb/pricing/details/app-service/windows/){:target="_blank"}

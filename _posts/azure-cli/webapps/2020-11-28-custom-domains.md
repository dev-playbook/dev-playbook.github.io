---
title: Azure Web Apps with Custom Domain
index: 80
layout: post
date: 2020-11-28 12:00
categories: 
    - Azure CLI
    - Azure WebApps
permalink: azure-cli/webapps/custom-domains
tags: 
    - devops
    - custom domains
description: This tutorial in Azure Web Apps shows how to configure custom domains.
---
>tl;dr
>```shell
># 1. get custom domain verification id and public ip from azure portal
># 2. map custom domains from the domain provider
># 3. add custom domain to web app using `az webapp config hostname`
>az webapp config hostname add --hostname {custom domain}
>```

## **Introduction**

{{page.description}} **Note that this tutorial will be using the [Basic Service Plan for Linux](https://azure.microsoft.com/en-gb/pricing/details/app-service/linux/){:target="_blank"}**.

{%include az-cli/000-prerequisites.md%}

## **Prepare**
{%include az-cli/005-login-account.md%}
{% include az-cli/010-create-resource-group.md %}

## **Create Web App**
{% include az-cli/020-create-app-service.md sku="B1" %}
{% include az-cli/030-create-webapp-nodejs.md%}

## **Deploy Source**
1. Configure the source of the deployment to the _main_ branch of a GitHub repository.

    ```shell
    repourl="https://github.com/dev-playbook/nodejs-env-request-vars.git"
    az webapp deployment source config --repo-url $repourl --branch main --manual-integration --verbose
    ```
    The source contains a small NodeJs application.
{% include az-cli/040-browse-webapp.md %}
    Expect a page with a _Hello World_ message and a list of key-value pairs from the environment variables and the HTTP request.

## **Create Custom Domains**

1. Get the Custom Domain Verification Id and public IP address from Azure Portal.

    Login your account in [Azure Portal](http://portal.azure.com){:target="_blank"} and navigate as follows.
    - Search for and select 'App Services'
    - Select 'webapp-demo-app-{RANDOM}' from the resulting table.
    - Select 'Custom domains' under Setting on the left-hand pane.
    - From the page, note the web app's 'IP Address' and 'Custom Domain Verification Id'

1. Map the custom domains from the domain provider.

    Go to the web portal of your domain provider, find the page for managing the DNS settings and add the following records.

    **Root domain**
        
    | Record Type | Host Name | Value |
    | TXT | asuid | {Custom Domain Verification Id} |
    | A | @ | {web app's IP address} |

    `TXT` record is accessed to verify root domain ownership. `A` record maps the web app's IP address to the custom root domain.

    **www sub-domain**

    | Record Type | Host Name | Value |
    | TXT | asuid.www | {Custom Domain Verification Id} |
    | CNAME | www | {appname}.azurewebsites.net |

    `TXT` record is accessed by the App Service to verify ownership of the `www` sub domain. `CNAME` record maps `{appname}.azurewebsites.net` to `www.{root domain}`.

    **Wildcard sub-domain**

    | Record Type | Host Name | Value |
    | CNAME | * | {appname}.azurewebsites.net  |

    `TXT` record for the root domain will suffice in verifying ownership for all other sub-domains. `CNAME` record maps `{appname}.azurewebsites.net` to `{sub domain}.{root domain}`.

    >In actual scenarios, you could have different web apps with their unique CDV ids mapped to their CNAME and TXT records while sharing the same custom root domain.

1. Map web apps hostnames to custom domains.
    ```shell
    customRootDomain={custom root domain}
    az webapp config hostname add --hostname $customRootDomain
    az webapp config hostname add --hostname www.$customRootDomain
    az webapp config hostname add --hostname foobar.$customRootDomain
    ```
    Expect all `az webapp config` call results to include `"hostNameType": "Verified"`.

    >If the DNS settings have not been configured correctly, expect error '_A TXT record pointing from asuid.{sub domain}.{root domain} to {CDV id} was not found_'.

1. Test the new custom domains.

    ```shell
    xdg-open http://$customRootDomain
    xdg-open http://www.$customRootDomain
    xdg-open http://foobar.$customRootDomain
    ```
    Expect a _Hello World_ page.

## **Clean up**
{% include az-cli/999-cleanup.md %}

## **Further Reading**

- [Map a custom domain to an App Service app using CLI](https://docs.microsoft.com/en-us/azure/app-service/scripts/cli-configure-custom-domain){:target="_blank"}
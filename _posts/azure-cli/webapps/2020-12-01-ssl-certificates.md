---
title: Azure Web Apps with SSL Certificates
index: 90
layout: post
date: 2020-11-28 12:00
categories: 
    - Azure CLI
    - Azure WebApps
permalink: azure-cli/webapps/ssl-certificates
tags: 
    - devops
    - ssl certificates
description: This tutorial in Azure Web Apps shows how to configure ssl certificates to webapps.
---
>tl;dr
>```shell
># create app service managed ssl certificate (and extract its thumbprint)
>az webapp config ssl create --hostname {web app domain} --name {app name} --query thumbprint
>
># upload an ssl certificate (and extract its thumbprint)
>az webapp config ssl upload --certificate-file {PKCS#12 format certificate file} \
>       --certificate-password {certificates export password} \
>       --query thumbprint
>
># bind the ssl certificate by its thumbprint to the web app's domains
>az webapp config ssl bind --certificate-thumbprint {thumbprint} --ssl-type SNI
>```

## **Introduction**

{{page.description}} **Note that this tutorial will be using the [Basic Service Plan for Linux](https://azure.microsoft.com/en-gb/pricing/details/app-service/linux/){:target="_blank"}**.

## **Prepare**

1. Complete the _[Custom Domains Tutorial]({% link _posts/azure-cli/webapps/2020-11-28-custom-domains.md %})_ excluding Clean Up.

1. Confirm the default arguments to `az` command for _group_ and _web_ are configured.
    ```shell
    az configure --list-defaults --output table
    ```

1. Ensure that variable $appname has the value of the web app's name.

    ```shell
    [[ -z "$appname" ]] && appname=$(az webapp show --query "name" --output tsv | sed -E "s/\r//g")
    echo $appname
    ```

1. Confirm the new custom domains.

    ```shell
    xdg-open http://www.$customRootDomain
    xdg-open http://foobar.$customRootDomain
    ```
    Expect a _Hello World_ page.

## **Create and Bind SSL Certificate to WWW Sub-Domain**

1. Create an SSL certificate for `www` sub domain.

    ```shell
    wwwSslThumbprint=$(az webapp config ssl create --hostname www.$customRootDomain --name $appname --query thumbprint --output tsv | sed "s/\r//g")
    echo $wwwSslThumbprint
    ```
    This creates an App Service Managed SSL certificate, and returns the thumbprint.

    >Note the `sed` removes rouge `\r` (carriage return)

    >The hostname can be any valid domain that the web app is mapped to.

    >To recall the certificate's thumbprint for a given hostname
    >```
    >az webapp config ssl list --query "[?subjectName=='www.$customRootDomain'].thumbprint" --output tsv | sed -E "s/\r//g"
    >```
    
2. Bind the SSL Certificate. 

    ```shell
    az webapp config ssl bind --certificate-thumbprint $wwwSslThumbprint --ssl-type SNI
    ```

    From the resulting payload, expect this object from `hostNameSslStates`, confirming the binding.
    ```json
    {
      "hostType": "Standard",
      "ipBasedSslResult": null,
      "ipBasedSslState": "NotConfigured",
      "name": "www.{custom root domain}",
      "sslState": "SniEnabled",
      "thumbprint": "{www ssl thumprint}",
      "toUpdate": null,
      "toUpdateIpBasedSsl": null,
      "virtualIp": null
    }
    ```

3. Test the site via the HTTPS protocol.

    ```shell
    xdg-open https://www.$customRootDomain
    ```

## **Use a Self Certified Certificate**

1. Generate a private key.

    ```shell
    openssl genrsa 2048 > private.pem
    ```

1. Create a Certificat Signing Request.

    ```shell
    openssl req -x509 -new -key private.pem -out public.pem \
            -subj "/CN=foobar.$customRootDomain" \
            -addext "extendedKeyUsage=serverAuth"
    ```
    Note that Common Name (CN) has been set to a `foobar` sub domain.

    >The Common Name can be any valid domain that the web app is mapped to.

1. Convert private key format to PKCS#12.

    ```shell
    openssl pkcs12 -export -in public.pem -inkey private.pem -out mycert.pfx
    ```
    Leave the export password blank when asked.

1. Upload the new certificate and extract the thumbprint.

    ```shell
    foobarSslThumbprint=$(az webapp config ssl upload --certificate-file mycert.pfx --certificate-password '' --query thumbprint --output tsv | sed "s/\r//g")
    echo $foobarSslThumbprint
    ```

1. Bind the Self Certified SSL Certificate. 

    ```shell
    az webapp config ssl bind --certificate-thumbprint $foobarSslThumbprint --ssl-type SNI --verbose
    ```

    From the resulting payload, expect this object from `hostNameSslStates`, confirming the binding.
    ```json
    {
      "hostType": "Standard",
      "ipBasedSslResult": null,
      "ipBasedSslState": "NotConfigured",
      "name": "foobar.{custom root domain}",
      "sslState": "SniEnabled",
      "thumbprint": "{foobar ssl thumbprint}",
      "toUpdate": null,
      "toUpdateIpBasedSsl": null,
      "virtualIp": null
    }
    ```

1. Test the sub domain using the HTTPS protocol.

    ```shell
    xdg-open https://foobar.$customRootDomain
    ```
    Since the certificate is self-certified, expect to see an `ERR_CERT_AUTHORITY_INVALID` error; proceed nonetheless.

## **Activity Logs**

1. View activity logs in Certificates.

    ```shell
    az monitor activity-log list --query "[?resourceType.value=='Microsoft.Web/certificates']" > log2.txt
    ```
    Open the file `log.txt` to view the activity log entries made during the tutorial.


## **Clean up**
{% include az-cli/999-cleanup.md %}

## **Further Reading**

- [OpenSSL Quick Reference Guide](https://www.digicert.com/kb/ssl-support/openssl-quick-reference-guide.htm){:target="_blank"}
# Deploy with Local Git

1. Open PowerShell and navigate to a working folder.

1. Create a starter Express NodeJS website.

        npm install -g express-generator

        npx express-generator express-app --view pug --git

        cd .\express-app

    Run it locally by executing the following, and test it by navigating to http://localhost:3000 using a browser. 

        npm install

        npm start
        
1. Login to your Azure account. 

        az login

1. Create a resource group and default subsequent commands to the group and location West US

        $rg = 'webapp-demo-rg'

        $location = 'westus'

        az group create --name $rg --location $location

        az configure --defaults group=$rg location=$location

1. Create an Azure App Service Plan, with Free SKU and Linux platform

        $planname = "webapp-demo-asplan"

        az appservice plan create --name $planname --sku F1 --is-linux

1. Create the web app using the new app service plan, with a unique name and running a version of node

        $appname = "webapp-demo-app-$(Get-Random)"

        az webapp create --name $appname --plan $planname --% --runtime "node|12-lts" --verbose

    Alternative runtimes available from the defaulted location can be queried as follows

        az webapp list-runtimes

1. Test the new web app by navigating to the placeholder website

        az webapp browse --name $appname

    Alternatively, get the default host name and use the value to navigate to the site with a browser.

        az webapp show --name $appname --query "defaultHostName" --out tsv

1. Set the deployment source of the web app to the local git

        az webapp deployment source config-local-git --name $appname

1. Setup the local git repository

        git init

        git add -A

        git config user.name 'foo-git-user'

        git config user.email 'foo-git-user@bar.qux'

        git commit -m 'initial commit'

1. Link the local git repository to remote 

        $remoteUrl = "https://$appname.scm.azurewebsites.net/$appname.git"

        git remote add origin $remoteUrl

    Note the remote repository is maintained by Kudu Source Control Management.

1. Get credentials for deployment. You have two options.

    - You can use *user-level credentials* for git and FTP that are directly tied to a Microsoft Account, so this is global to all your Azure Web Apps not just this app. You can set or reset the user credentials by executing the following with the appropriate _{username}_ and _{password}_

            az webapp deployment user set --user-name '{username}' --password '{password}'

    - You can also use *site-level credentials* automatically generated when the web app was created. The username is the app name then prefixed by $ (e.g. $webapp-demo-app-_random_).
    
        The username and password can be extracted using PowerShell by downloading the publisher profile of the app, and filtering <code>userPWD</code> from either the MSDeploy or FTP profile.

            $xml = [xml](Get-AzWebAppPublishingProfile -Name $appname -ResourceGroupName $rg)

            Select-Xml -XML $xml -XPath '/publishData/publishProfile[@publishMethod="MSDeploy"]' `
            | Select -ExpandProperty Node | Select userName, userPWD

        The password can also be extracted by listing the publishing credentials using Azure CLI.

            az webapp deployment list-publishing-credentials --name $appname | grep -E "publishing(UserName|Password)"

1. Push to the remote git repository, entering your chosen username and password.

        git config credential.helper store

        git push --set-upstream origin master

    Note the output should return a successful build and deployment by Kudu.

    Git configuration has also been altered in order to store the credentials.

1. Test the deployed web app.

        az webapp browse --name $appname

1. Monitor the web app logs stream

        az webapp log tail --name $appname

    Refresh the browser page and expect new [INFO] messages. Press Ctrl-C to close the stream.

1. Push changes to source code and deploy.

        cp .\routes\index.js .\routes\index.js.old

        $code = cat .\routes\index.js.old

        $code = $code -replace "title: 'Express'", "title: 'Hello World!'"

        $code | Out-File .\routes\index.js -Encoding UTF8

        git add .\routes\index.js

        git commit -m 'updated .\routes\index.js'

    Note the output should return a successful build and deployment by Kudu.

    Also note that you no longer need to enter credentials as it was stored previously.

    Test the deployed web app and expect an altered page.

        az webapp browse --name $appname

1. You can analyze and manage the app deployment by visiting the Kudu Source Control Management site of the web app.

        Start-Process "https://$appname.scm.azurewebsites.net/"

1. You can download the logs of this web app by executing the following.

        az webapp log download --name $appname --log-file .\webapp-demo.zip

1. Clean up by deleting the resources created in the default group.

        az group delete --yes

### References

- [Deploy to Azure App Service using the Azure CLI](https://docs.microsoft.com/en-us/azure/developer/javascript/tutorial-vscode-azure-cli-node-01)

- [Deployment Credentials](https://github.com/projectkudu/kudu/wiki/Deployment-credentials#user-level-credentials-aka-deployment-credentials)

- [Using Kudu and deploying apps into Azure](https://techcommunity.microsoft.com/t5/educator-developer-blog/using-kudu-and-deploying-apps-into-azure/ba-p/378585)

- [az webapp log show](https://docs.microsoft.com/en-us/cli/azure/webapp/log?view=azure-cli-latest#az_webapp_log_show)
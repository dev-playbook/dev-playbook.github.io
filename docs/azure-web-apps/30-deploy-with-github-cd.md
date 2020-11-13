---
title: Deploy from GitHub with Continuous Deployment
---

#### Create an Azure Web App
1. Create a resource group and default subsequent commands to group and location West US

        $rg = 'webapp-demo-rg'
        $location = 'westus'
        az group create --name $rg --location $location
        az configure --defaults group=$rg location=$location

1. Create an Azure App Service Plan with FREE sku in the Linux platform
 
        $planname = 'webapp-demo-asplan'
        az appservice plan create --name $planname --sku FREE --is-linux

1. Create the web app using the new app service plan, with a unique name and running a version of node

        $appname = "webapp-demo-app-$(Get-Random)"
        az webapp create --name $appname --plan $planname --% --runtime "node|12-lts"

1. Test the new web app by navigating to the placeholder website

        az webapp browse --name $appname

#### Create a small NodeJS app

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

        const server = http.createServer((request, response) => {
            response.writeHead(200, {"Content-Type": "text/plain"});
            response.end("Version 1: Hello World!");
        });

        const port = process.env.PORT || 1337;

        server.listen(port);

1. Start the NodeJs app locally and test by navigating to http://localhost:1337 with a browser.

        npm start

#### Setup a GitHub repository 

1. Go to your GitHub account and [create a public repository](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/create-a-repo) with name <code>www-app</code>.

1. Setup a local git repository

        git init
        git add -A
        git config user.name 'foo-git-user'
        git config user.email 'foo-git-user@bar.qux'
        git commit -m 'initial commit'

1. Link the local repository to GitHub remote repository.

        git config credential.helper store
        $repourl = "https://github.com/{github-username}/www-app.git"
        git remote add origin $repourl 
        git push -u origin master

    Note that you will need to replace <code>{github-username}</code> with the appropriate value.

#### Deploy web app

1. From your GitHub account, [obtain a personal access token](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token) with ONLY the following permissions granted.

        write:repo_hook
        read:repo_hook

    Store the personal access token to a variable for later use.

        $token = {personal access token}

1. Deploy the source code from the GitHub.

        az webapp deployment source config --name $appname `
                --repo-url $repourl --branch master --git-token $token `
                --verbose

1. Test the resulting site.
            
        az webapp browse --name $appname

    Expect the output to be as follows

        Version 1: Hello World!

#### Test the continuous deployment

1. Push a small change to the app

        cp .\app.js .\app.js.old
        (cat .\app.js.old) -replace 'Version 1', 'Version 2' | Out-File .\app.js -Encoding UTF8
        git add .\app.js
        git commit -m 'updated to Version 2'
        git push

1. Test the web app 

        az webapp browse --name $appname

    Expect the output to change as follows

        Version 2: Hello World!

#### Analysing the deployment logs

To view the deployment history, execute the following.

        az webapp log deployment list --name $appname

The top entry refers to the latest deployment, while subsequent entries are historic.

Each entry have the following useful information.

- <code>active</code> is <code>true</code> when this is the active deployment; all others are <code>false</code>.
- <code>id</code> is the _deployment id_ and is the same as commit id in the git repository.
- <code>message</code> is the comment taken from git commit.
- <code>url</code> is a link to same list entry.
- <code>log_url</code> is a link to the logs of this deployment.
- <code>status</code> of 4 means a successful deployment.

To view the logs of the latest deployment, execute the following.

        az webapp log deployment show --name $appname

The following are typical log entry messages of a successful deployment.

        Updating submodules.
        Preparing deployment for commit id '{git commit id}'.
        Repository path is /home/site/repository
        Running oryx build...                           
        Running post deployment command(s)...
        Triggering recycle (preview mode disabled).
        Deployment successful.

To view the logs of historic deployments, you have two options.

- You can navigate to the <code>log_url</code> link from the result of '<code>az webapp log deployment list</code>'.
    
- Alternatively execute the following with the _commit id_ specified.

        az webapp log deployment show --name $appname --deployment-id {commit id}

## Clean up

1. Delete resources created in the group.

        az group delete --yes

1. Delete the <code>www-app</code> repository from you GitHub account.

#### References

- [Create an App Service app with continuous deployment from GitHub using CLI](https://docs.microsoft.com/en-us/azure/app-service/scripts/cli-continuous-deployment-github)

- [GitHub: Creating a personal access token
](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/creating-a-personal-access-token)
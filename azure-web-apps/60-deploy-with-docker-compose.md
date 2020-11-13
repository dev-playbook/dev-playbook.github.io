# Deploy with Docker Compose

1. Open command line or PowerShell and login to azure

        az login

1. Get the code sample from azure Samples and change directory

        git clone https://github.com/Azure-Samples/multicontainerwordpress

        cd .\multicontainerwordpress

1. Create a resource group and default subsequent commands to group and location East US

        $rg = 'webapp-demo-rg'

        $location = 'eastus'

        az group create --name $rg --location $location

        az configure --defaults group=$rg location=$location

1. Create an Azure App Service Plan
 
        $planname = 'webapp-demo-asplan'

        az appservice plan create --name $planname --sku S1 --is-linux

1. Create a docker compose application

        $appname = "webapp-demo-$(Get-Random)"

        az webapp create --plan $planname --name $appname `
            --multicontainer-config-type compose `
            --multicontainer-config-file .\docker-compose-wordpress.yml

    The app may take a few minutes to load. If you receive an error, allow a few more minutes then refresh the browser. If you're having trouble and would like to troubleshoot, review container logs.

        az webapp browse --name $appname

1. List the resources created and expect site <code>webapp-demo-_{random}_</code> and service plan <code>webapp-demo-asplan</code> to exist.

        az resource list --output table

1. Clean up by deleting all resources in the group

        az group delete --yes

### References

> https://docs.microsoft.com/en-us/azure/container-instances/tutorial-docker-compose
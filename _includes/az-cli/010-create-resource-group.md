{% if include.location == 'us' %}
1. Create a resource group in West US where the web app will be deployed.

    ```shell
    rg='webapp-demo-rg'
    location='westus'
    az group create --name $rg --location $location --verbose
{% else %}
1. Create a resource group in West UK where the web app will be deployed.

    ```shell
    rg='webapp-demo-rg'
    location='ukwest'
    az group create --name $rg --location $location --verbose
{% endif %}
    az configure --defaults group=$rg location=$location
    az configure --list-defaults --output table
    ```
    Results should include details of the new group including allocated id and _provising state_ as _Succeeded_.
    
    Also, defaults for _group_ and _location_ have been added to Azure cli. From here on, subsequent <code>az</code> commands will omit arguments to <code>--resource-group</code> and <code>--location</code>.
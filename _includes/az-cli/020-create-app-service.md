1. Create an Azure App Service Plan with {{ include.sku }} SKU in the Linux platform

    ```shell
    planname='webapp-demo-asplan'
    az appservice plan create --name $planname --sku {{ include.sku }} --is-linux --verbose
    ```
    Results should include details of the new service plan, including its Id, SKU details and provisioning state as _Succeeded_.

{% include az-cli/021-info-app-service-tiers.md sku=include.sku%}

1. Upgrade the app service plan to {{ include.sku }} SKU.

    ```shell
    planId=$(az webapp show --query appServicePlanId | sed -e s/\"//g)
    az appservice plan update --ids $planId --sku S1 --verbose
    ```
    Results should include details of the upgraded service plan, including its Id, SKU details and provisioning state as _Succeeded_.

{% include az-cli/021-info-app-service-tiers.md %}

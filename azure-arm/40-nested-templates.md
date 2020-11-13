---
layout: page
---
# Nested Templates

1. Open PowerShell and create a working folder

1. Create template <code>arm-demo-store-acc-1.json</code> with the following content.

        {
            "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {
                "storageAccountName": {
                    "type": "string"
                }
            },
            "resources": [
            {
                "type": "Microsoft.Resources/deployments",
                "apiVersion": "2019-10-01",
                "name": "nestedTemplate1",
                "properties": {
                    "mode": "Incremental",
                    "template": {
                        "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
                        "contentVersion": "1.0.0.0",
                        "resources": [
                        {
                            "type": "Microsoft.Storage/storageAccounts",
                            "apiVersion": "2019-04-01",
                            "name": "[parameters('storageAccountName')]",
                            "location": "West US",
                            "sku": {
                                "name": "Standard_LRS"
                            },
                            "kind": "StorageV2"
                        }
                        ]
                    }
                }
            }
            ],
            "outputs": {
            }
        }

    Note the following:
    - The template has resource <code>nestedTemplate1</code> of type _deployments_
    - Nested template <code>nestedTemplate1</code> has the storage account resource description.

1. Create a resource group where the storage account will be created

        New-AzResourceGroup arm-demo-rg -Location 'uksouth'

1. Run the template

        New-AzResourceGroupDeployment `
            -Name arm-demo-nested-template-1 `
            -ResourceGroupName arm-demo-rg `
            -TemplateUri "$(pwd)\arm-demo-store-acc-1.json" `
            -StorageAccountName armdemostoreacc1 `
            -Verbose

1. List all the resources in the group

        Get-AzResource -ResourceGroupName arm-demo-rg

    Note that <code>armdemostoreacc1</code> exists.

1. Get the resource group deployment for the group

        Get-AzResourceGroupDeployment arm-demo-grp

    Note that the provisioning state is _Succeeded_ and the mode is _Incremental_.

1. Clean up by removing the resource group.

        Remove-AzResourceGroup arm-demo-rg
---
layout: page
---
# Using Key Vaults

1. Open PowerShell and create a working folder

1. Create a resource group

        New-AzResourceGroup arm-demo-rg -Location uksouth

1. Create a key vault where the secret value will be stored, ensuring that template deployment is allowed.

        New-AzKeyVault -Name arm-demo-key-vault `
            -ResourceGroupName arm-demo-rg `
            -Location uksouth `
            -EnabledForTemplateDeployment

1. Add your principal names to the key vault access policy

        $principalNames = Get-AzADUser | Select -ExpandProperty UserPrincipalName

        $principalNames | ForEach ( {
                Set-AzKeyVaultAccessPolicy -VaultName arm-demo-key-vault `
                    -UserPrincipalName $_ `
                    -PermissionsToSecrets get, set, delete, list `
            })

1. Save a secret value for <code>ExamplePassword</code> key to the vault.

        $secretvalue = ConvertTo-SecureString 'hVFkk965BuUv' -AsPlainText -Force

        Set-AzKeyVaultSecret -VaultName arm-demo-key-vault `
            -Name 'ExamplePassword' `
            -SecretValue $secretvalue

1. Create template <code>arm-demo-key-vault-test.json</code> with the following content.

        {
            "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {
                "secretValue": { "type": "securestring" }
            },
            "resources": [],
            "outputs": {
                "secureSecret": {
                    "type": "securestring",
                    "value": "[parameters('secretValue')]"
                },
                "secret": {
                    "type": "string",
                    "value": "[parameters('secretValue')]"
                }
            }
        }

    This template simply outputs the argument to <code>secretValue</code> parameter.

1. Note the resource id of the key vault

        (Get-AzKeyVault -VaultName arm-demo-key-vault).ResourceId

1. Create template <code>arm-demo-key-vault-test.parameters.json</code> with the following content, replacing _{keyVaultResourceId}_ with the resource id of the key value vault.

        {
            "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {
                "secretValue": {
                    "reference": {
                        "keyVault": {
                            "id": "{keyVaultResourceId}"
                        },
                        "secretName": "ExamplePassword"
                    }
                }
            }
        }

    This will act as the parameters file for <code>arm-demo-key-vault-test.json</code>, and will pass the secret key value of <code>ExamplePassword</code> as argument for <code>secretValue</code> parameter.

1. Run the template

        New-AzResourceGroupDeployment -ResourceGroupName arm-demo-rg `
            -TemplateFile "$(pwd)\arm-demo-key-vault-test.json" `
            -TemplateParameterFile "$(pwd)\arm-demo-key-vault-test.parameters.json" `
            -Verbose

    Note the output in result should include the secret value stored in the vault.

1. Clean up by deleting the resource group.

        Remove-AzResourceGroup arm-demo-rg -AsJob
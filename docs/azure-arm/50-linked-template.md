---
layout: page
---
# Liked Template

1. Open PowerShell and create a working folder

1. Create a working group

        New-AzResourceGroup arm-demo-rg -Location 'uksouth'

1. Create template <code>arm-demo-linked-template.json</code> with the following content.

        {
            "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {
                "vm1Name": {
                    "type": "string",
                    "metadata": {
                        "description": "Name for the Virtual Machine."
                    }
                },
                "vm2Name": {
                    "type": "string",
                    "metadata": {
                        "description": "Name for the Virtual Machine."
                    }
                },
                "sshKey": {
                    "type": "securestring",
                    "metadata": {
                        "description": "SSH Key or password for the Virtual Machine. SSH key is recommended."
                    }
                }
            },
            "variables": {
                "vmSize": "Standard_B1S",
                "authenticationType": "sshPublicKey",
                "location": "[resourceGroup().location]",
                "adminUsername": "demoadmin"
            },
            "resources": [
                {
                    "name": "linked-template-1",
                    "type": "Microsoft.Resources/deployments",
                    "apiVersion": "2020-06-01",
                    "properties": {
                        "mode": "Incremental",
                        "templateLink": {
                            "uri": "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-rhel/azuredeploy.json",
                            "contentVersion": "1.0.0.0"
                        },
                        "parameters": {
                            "adminPasswordOrKey": { "value": "[parameters('sshKey')]" },
                            "authenticationType": { "value": "[variables('authenticationType')]" },
                            "vmName": { "value": "[parameters('vm1Name')]" },
                            "vmSize": { "value": "[variables('vmSize')]" },
                            "location": { "value": "[variables('location')]" },
                            "adminUsername": { "value": "[variables('adminUsername')]" }
                        }
                    }
                },
                {
                    "name": "linked-template-2",
                    "type": "Microsoft.Resources/deployments",
                    "apiVersion": "2019-10-01",
                    "properties": {
                        "mode": "Incremental",
                        "templateLink": {
                            "uri": "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-rhel/azuredeploy.json",
                            "contentVersion": "1.0.0.0"
                        },
                        "parameters": {
                            "adminPasswordOrKey": { "value": "[parameters('sshKey')]" },
                            "authenticationType": { "value": "[variables('authenticationType')]" },
                            "vmName": { "value": "[parameters('vm2Name')]" },
                            "vmSize": { "value": "[variables('vmSize')]" },
                            "location": { "value": "[variables('location')]" },
                            "adminUsername": { "value": "[variables('adminUsername')]" }
                        }
                    }
                }
            ],
            "outputs": {
            }
        }

    This template will be used to create 2 RedHat Enterprise Linux machines by using https links to templates stored in git hub. This template also delegates arguments to the linked template thru parameters and variable.

1. Deploy the template

        $sshKey = Get-Content ~/.ssh/id_rsa.pub | ConvertTo-SecureString -AsPlainText -Force

        New-AzResourceGroupDeployment `
            -ResourceGroupName arm-demo-rg `
            -TemplateUri "$(pwd)\arm-demo-linked-template.json" `
            -Vm1Name arm-demo-vm-1 `
            -Vm2Name arm-demo-vm-2 `
            -SshKey $sshKey `
            -Verbose

1. Confirm the resources created by listing the resources in the group.

        Get-AzResource -ResourceGroupName arm-demo-rg | Format-Table

1. Test one of the linux machines by starting an SSH session.

        $ipAddress = Get-AzPublicIpAddress -ResourceGroupName arm-demo-rg | Select -ExpandProperty IpAddress -First 1 

        ssh demoadmin@$ipAddress

1. Clean up by delete all resources in the group.

        Remove-AzResourceGroup arm-demo-rg -AsJob



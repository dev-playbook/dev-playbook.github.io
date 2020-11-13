---
layout: page
---
# Deploying a Resource Group using Azure Resource Manager Templates

1. Open PowerShell

1. Login to the azure account

        Connect-AzAccount

1. Create a group where the resources will be deployed

        New-AzResourceGroup arm-demo-grp-1 -Location 'uksouth'

1. Create a working folder

        New-Item -ItemType directory ./demo-arm

        Set-Location ./demo-arm

1. Use the URI address of an existing template from Azure Quick Templates for creating a RedHat Enterprise Linux virtual machine

        $templateUri = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-rhel/azuredeploy.json'

1. Extract your Secure Shell Protocol public key to a secure string

        $sshKeyContent = Get-Content ~/.ssh/id_rsa.pub

        $sshKey = $sshKeyContent | ConvertTo-SecureString -asplaintext -force

    If it does not exist, then create key pair beforehand
 
        ssh-keygen -m PEM -t rsa -b 4096

1. Create a template parameter file <code>my-params.json</code> with the following content.

        {
            "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {
                "adminUsername": { "value": "demoadmin" },
                "authenticationType": { "value": "sshPublicKey" },
                "vmSize": { "value": "Standard_B1S" },
                "location": { "value": "uksouth" }
            }
        }

1. Create a virtual machine <code>arm-demo-rhel-1</code> by passing the template url.

        New-AzResourceGroupDeployment `
            -ResourceGroupName 'arm-demo-grp-1' `
            -TemplateUri $templateUri `
            -TemplateParameterFile './my-params.json' `
            -VmName 'arm-demo-rhel-1' `
            -AdminPasswordOrKey $sshKey `
            -Verbose

    Template parameter file and secure SSH key are also passed.

1. List all resources created

        Get-AzResource -ResourceGroup arm-demo-grp-1 | Format-Table

1. Test the virtual machine by connecting a SSH session.

        $ipAddress = (Get-AzPublicIPAddress).IpAddress

        ssh demoadmin@$ipAddress

1. Create virtual machine <code>arm-demo-rhel-2</code> by passing the template downloaded from template Url.

        $template = (wget $templateUri).Content

        New-AzResourceGroupDeployment `
            -ResourceGroupName 'arm-demo-grp-1' `
            -Template $template `
            -TemplateParameterFile './my-params.json' `
            -VmName 'arm-demo-rhel-2' `
            -AdminPasswordOrKey $sshKey `
            -Verbose
        
    Template parameter file and secure SSH key are also passed.

    Note the Mode defaults to _Increment_. This means <code>arm-demo-rhel-1</code> and their dependent resources remains in the resource group. Confirm by executing the following.
    
        Get-AzResource -ResourceGroup arm-demo-grp-1 | Format-Table

1. Create virtual machine <code>arm-demo-rhel-3</code>, passing the same parameters as above for <code>arm-demo-rhel-1</code>

        New-AzResourceGroupDeployment `
            -ResourceGroupName 'arm-demo-grp-1' `
            -TemplateUri $templateUri `
            -TemplateParameterFile './my-params.json' `
            -VmName 'arm-demo-rhel-3' `
            -AdminPasswordOrKey $sshKey `
            -Mode Complete `
            -Verbose

    Note the Mode is set as _Complete_. This means that  created for <code>arm-demo-rhel-1</code>, <code>arm-demo-rhel-2</code> and their depended resources are deleted. Confirm by executing the following.

        Get-AzResource -ResourceGroup arm-demo-grp-1 | Format-Table

1. Clean up by deleting all resources in the resource group

        Remove-AzResourceGroup arm-demo-grp-1


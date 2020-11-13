---
layout: page
---
# Provision Linux VM using ARM Template

1. Open command or PowerShell prompt and create a working folder

1. Clone the git repository

    git clone https://github.com/Azure/azure-quickstart-templates

1. Change working directory to <code>101-vm-simple-rhel</code>

        cd azure-quickstart-templates\101-vm-simple-rhel

1. Login to the account and set the account subscription

        Connect-AzAccount -Subscription "<subscription name>"

1. Create a resource group

        New-AzResourceGroup vm-demo-arm-1 -Location 'uksouth'

1. Extract your local public ssh key 

        $sshKeyContent = Get-Content ~/.ssh/id_rsa.pub

        $sshKey = $sshKeyContent | ConvertTo-SecureString -asplaintext -force

    If no public key exist, then run the following command beforehand

        ssh-keygen -m PEM -t rsa -b 4096

1. Deploy the RedHat Enterprise Linux machine to a new resource group, passing down the arguments to template's parameters.

        New-AzResourceGroupDeployment `
            -ResourceGroupName vm-demo-arm-1 `
            -TemplateFile ./azuredeploy.json `
            -AuthenticationType 'sshPublicKey' `
            -AdminUserName "demoadmin" `
            -AdminPasswordOrKey $sshKey `
            -VmName 'vm-demo-rhel-1' `
            -Location 'uksouth' `
            -VmSize 'Standard_B1S'

1. Test the new virtual machine by starting a Secure Shell session 

        $ipAddress = (Get-AzPublicIpAddress).IpAddress

        ssh demoadmin@$ipAddress

1. You can also use a template parameter object to pass arguments. But, note that you are passing the SSH key content and not the secure string.

        $params = @{
            authenticationType = "sshPublicKey"
            adminUserName = "demoadmin"
            adminPasswordOrKey = $sshKeyContent
            vmName = "vm-demo-rhel-2"
            location = "uksouth"
            vmSize = "Standard_B1S" 
        }

        $deployment = New-AzResourceGroupDeployment `
            -ResourceGroupName vm-demo-arm-1 `
            -TemplateFile ./azuredeploy.json `
            -TemplateParameterObject $params `
            -Verbose

1. You can also contain all arguments in a parameter file.

    Create a file <code>my-params.json</code> with the following content.

        {
            "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
            "contentVersion": "1.0.0.0",
            "parameters": {
                "adminUsername": { "value": "demoadmin" },
                "authenticationType": { "value": "sshPublicKey" },
                "adminPasswordOrKey": { "value": "<sshkey>" },
                "vmName": { "value": "vm-demo-rhel-3" },
                "vmSize": { "value": "Standard_B1S" },
                "location": { "value": "uksouth" }
            }
        }

    You will need to substitute the <code><sshkey></code> with your SSH public key.

        (Get-Content .\my-params.json -Raw) `
            -replace '<sshKey>', $sshKeyContent `
            | Out-File .\my-params-1.json -Encoding utf8

    Execute the command to create the virtual machine, passing down the template and parameter files, and resource group name.

        $deployment = New-AzResourceGroupDeployment `
                -ResourceGroupName vm-demo-arm-1 `
                -TemplateFile ./azuredeploy.json `
                -TemplateParameterFile ./my-params-1.json `
                -Verbose

1. You can also use a URL like to the template.

        $templateUrl = 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-rhel/azuredeploy.json'

        $params = @{
            authenticationType = "sshPublicKey"
            adminUserName = "demoadmin"
            adminPasswordOrKey = $sshKeyContent
            vmName = "vm-demo-rhel-5"
            location = "uksouth"
            vmSize = "Standard_B1S" 
        }

        $deployment = New-AzResourceGroupDeployment `
                -ResourceGroupName vm-demo-arm-1 `
                -TemplateUri $templateUrl `
                -TemplateParameterFile './my-params-1.json' `
                -VmName "vm-demo-rhel-5" `
                -Verbose

1. Clean up by deleting the resource group

    Remove-AzResourceGroup vm-demo-arm-1
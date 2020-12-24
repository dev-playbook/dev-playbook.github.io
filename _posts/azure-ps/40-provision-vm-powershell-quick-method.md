---
layout: page
---
# Provision Linux VM using Azure PowerShell (Quick Method)

1. Create a virtual machine by passing a parameter set.

        $password = ConvertTo-SecureString '<password>' -AsPlainText -Force

        $credentials = New-Object System.Management.Automation.PSCredential ('demoadmin', $password)

        $vmParams = @{
            Name = 'vm-demo-rhel-1'
            Location = 'centralus'
            Size = 'Standard_B1S'
            Image = 'rhel'
            Credential = $credentials
            OpenPorts = 22
        }

        $vm = New-AzVM @vmParams

        This creates a virtual machine named <code>vm-demo-rhel-1<code> under a resource group under the same name.

1. Test the Windows Server VM by starting a Remote Desktop Protocol session 

        $ipAddress = $vm | Get-AzPublicIpAddress | Select-Object -ExpandProperty IpAddress

        ssh demoadmin@$ipAddress

1. Clean up by deleting the resource group

    Remove-AzResourceGroup -Name 'vm-demo-rhel-1'
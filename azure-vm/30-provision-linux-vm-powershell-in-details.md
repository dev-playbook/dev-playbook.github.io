---
layout: page
---
# Provision Linux VM using Azure PowerShell

1. Open PowerShell with Administrator privilages and install <code>Az</code>. Uninstall previous versions of AzureRM

        Install-Module Az

1. Open PowerShell with normal privilages.

1. Connect to account and subscription

        Connect-AzAccount -Subscription "<subscription name>"

1. Create a resource group

        $rg = New-AzResourceGroup -Name 'vm-demo-rg' -Location 'UK South' 

1. Create a virtual network with one subnet

        $subnetConfig = New-AzVirtualNetworkSubnetConfig `
            -Name 'vm-demo-subnet-2' `
            -AddressPrefix '10.2.1.0/24'

        $vnet = New-AzVirtualNetwork `
            -ResourceGroupName $rg.ResourceGroupName `
            -Location $rg.Location `
            -Name 'vm-demo-vnet-2' `
            -AddressPrefix '10.2.0.0/16' `
            -Subnet $subnetConfig

1. Create a new virtual machine config, setting the name and size.

        $LinuxVmConfig = New-AzVMConfig `
            -VMName 'vm-demo-linux-2' `
            -VMSize 'Standard_B1S'

    The machine is size to set to <code>Standard_B1S</code>. You can list alternative vm sizes by location.

        Get-AzVMSize -Location 'UK South'

1. Create a network security group with a rule to allow SSH traffic to port 22

        $rule1 = New-AzNetworkSecurityRuleConfig `
            -Name ssh-rule `
            -Description 'Allow SSH' `
            -Access Allow `
            -Protocol Tcp `
            -Direction Inbound `
            -Priority 100 `
            -SourceAddressPrefix Internet `
            -SourcePortRange * `
            -DestinationAddressPrefix * `
            -DestinationPortRange 22

        $nsg = New-AzNetworkSecurityGroup `
            -ResourceGroupName $rg.ResourceGroupName `
            -Location $rg.Location `
            -Name 'vm-demo-linux-nsg-2' `
            -SecurityRules $rule1

1. Create a network interface, with an allocated public IP address and subnet, and attach it to the vm config.

        $subnet = $vnet.Subnets | Where-Object { $_.Name -eq 'vm-demo-subnet-2' }

        $pip = New-AzPublicIpAddress `
            -ResourceGroupName $rg.ResourceGroupName `
            -Location $rg.Location `
            -Name 'vm-demo-linux-2-pip-1' `
            -AllocationMethod Static

        $nic = New-AzNetworkInterface `
            -ResourceGroupName $rg.ResourceGroupName `
            -Location $rg.Location `
            -Name 'vm-demo-linux-2-nic-1' `
            -Subnet $subnet `
            -PublicIpAddress $pip `
            -NetworkSecurityGroup $nsg

        $LinuxVmConfig = Add-AzVMNetworkInterface `
            -VM $LinuxVmConfig `
            -Id $nic.Id

1. Set the operating system as Linux to the vm config, with username/password credentials but password authentication disabled

        $password = ConvertTo-SecureString '<password>' -AsPlainText -Force

        $LinuxCred = New-Object System.Management.Automation.PSCredential ('demoadmin', $password)

        $LinuxVmConfig = Set-AzVMOperatingSystem `
            -VM $LinuxVmConfig `
            -Linux `
            -ComputerName 'vm-demo-linux-2' `
            -DisablePasswordAuthentication `
            -Credential $LinuxCred

1. Check for SSH key pair <code>id_rsa</code> and <code>id_rsa.pub</code> in <code>.ssh</code> folder are on your local machine. 
        
        dir ~/.ssh/id_rsa*

    If they dont exist, generate the keys using <code>ssh-keygen</code>.

        ssh-keygen -m PEM -t rsa -b 4096

    Finally, set the SSH public key to the vm config.
    
        $sshPublicKey = Get-Content '~/.ssh/id_rsa.pub'

        Add-AzVMSshPublicKey `
            -VM $LinuxVmConfig `
            -KeyData $sshPublicKey `
            -Path '/home/demoadmin/.ssh/authorized_keys'

1. Set the image of the virtual machine to the config

        $LinuxVmConfig = Set-AzVMSourceImage `
            -VM $LinuxVmConfig `
            -PublisherName 'Redhat' `
            -Offer 'rhel' `
            -Skus '7.4' `
            -Version 'latest'

    The image used is the latest build of <code>RedHat Enterprise Linux (rhel) 7.4<code>. You can traverse the alternative publishers, offers and Stock Keep Units (SKU) to find availble images by running the following.

        Get-AzVMImagePublisher -Location '{Location}'

        Get-AzVMImageOffer -Location $rg.Location -PublisherName '{Publisher}'
    
        Get-AzVMImageSku -Location $rg.Location -PublisherName '{Publisher}' -Offer '{Offer}'

        Get-AzVMImage -Location $rg.Location -PublisherName 'Redhat' -Offer 'rhel' -Skus '7.4'

1. Create the new virtual machine as set by the vm config.

        New-AzVM `
            -ResourceGroupName $rg.ResourceGroupName `
            -Location $rg.Location `
            -VM $LinuxVmConfig

1. Test the new virtual machine by starting a Secure Shell session

        $ipAddress = Get-AzPublicIpAddress `
            -ResourceGroupName $rg.ResourceGroupName `
            -Name $pip.Name | Select-Object -ExpandProperty IpAddress

        ssh demoadmin@$ipAddress

1. Clean up by deleting the resource group

        Remove-AzResourceGroup -Name vm-demo-rg

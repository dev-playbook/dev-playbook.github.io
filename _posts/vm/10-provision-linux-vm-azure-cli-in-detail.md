---
layout: page
---
# Provision Linux VM using Azure CLI

1. Open PowerShell

1. Login to the account and set the account subcription.

        az login 

        az account list --output table

        az account set --subscription "<subscription name>"

1. Create a resource group <code>vm-demo-group</code> to <code>uksouth</code> location to contain all resources created.

        az group create `
            --name "vm-demo-group" `
            --location "uksouth"

        az group list --output table 

1. Create virtual network <code>vm-demo-vnet-1</code>

        az network vnet create `
            --resource-group "vm-demo-group" `
            --name "vm-demo-vnet-1" `
            --address-prefix "10.1.0.0/16"

        az network vnet list `
            --resource-group "vm-demo-group" `
            --output table
            
    The vnet is allocated with ip addresses between 10.1.0.0 to 10.1.255.255
    
1. Create subnet <code>vm-demo-subnet-1</code> to the virtual network.

        az network vnet subnet create `
            --resource-group "vm-demo-group" `
            --name "vm-demo-subnet-1" `
            --vnet-name "vm-demo-vnet-1" `
            --address-prefixes "10.1.1.0/24"

        az network vnet subnet list `
            --resource-group "vm-demo-group" `
            --vnet-name "vm-demo-vnet-1" `
            --output table

    The subnet is allocated with ip addresses between 10.1.1.0 to 10.1.1.255

1. Create a public IP address for the virtual machine to be created

        az network public-ip create `
            --resource-group "vm-demo-group" `
            --name "vm-demo-linux1-pip-1"

        az network public-ip list --output table

    This allows connectivity of the virtual machine from the outside world.

1. Create network security group <code>vm-demo-linux-nsg-1</code>.

        az network nsg create `
            --resource-group "vm-demo-group" `
            --name "vm-demo-linux-nsg-1"

        az network nsg list --output table

    Once attached, this filters network traffic to and from other resources in the vnet. When created, its default to allowing all traffic and denies none.

1. Create network interface card <code>vm-demo-linux1-pip-1</code>.

        az network nic create `
            --resource-group "vm-demo-group" `
            --name "vm-demo-linux-1-nic-1" `
            --vnet-name "vm-demo-vnet-1" `
            --subnet "vm-demo-subnet-1" `
            --network-security-group "vm-demo-linux-nsg-1" `
            --public-ip-address "vm-demo-linux1-pip-1"

        az network nic list --output table

    Once attached, it enables the virtual machine to communicate with the internet, Azure, and on-premises resources. 
    
    Once allocated, the card belongs to subnet <code>vm-demo-subnet-1</code> in vnet <code>vm-demo-vnet-1</code>. Traffic is regulated thru <code>vm-demo-linux-nsg-1</code>

1. Check for SSH key pair <code>id_rsa</code> and <code>id_rsa.pub</code> in <code>.ssh</code> folder are on your local machine. Otherwise, generate the keys using <code>ssh-keygen</code>.

        dir ~/.ssh/id_rsa*

        ssh-keygen -m PEM -t rsa -b 4096

1. Create virtual machine <code>vm-demo-linux-1</code>.

        az vm create `
            --resource-group "vm-demo-group" `
            --name "vm-demo-linux-1" `
            --nics "vm-demo-linux-1-nic-1" `
            --image "rhel" `
            --size "Standard_B1S" `
            --admin-username demoadmin `
            --authentication-type "ssh"
            --generate-ssh-keys

        az vm list --output table
    
    The virtual machine uses the <code>rhel<code> image from RedHat; other available images can be listed by executing the following:

        az vm image list --output table

    The machine size is <code>Stadard B1S</code>; all other; other available sizes by location can be listed by executing the following:

        az vm list-sizes --location uksouth --output table

    The option <code>--generate-ssh-key</code> uses SSH key pairs <code>id_rsa</code> and <code>id_rsa.pub</code> in the <code>~/.ssh</code> folder. If none exist, then it automatically generates them.

1. Open port 22 to allow Secure Shell (SSH) traffic to <code>vm-demo-linux-1</code>.

        az vm open-port `
            --resource-group "vm-demo-group" `
            --name "vm-demo-linux-1" `
            --port "22"

1. Grab the public IP of the <code>vm-demo-linux-1</code>

        az vm list-ip-addresses --name "vm-demo-linux-1" --output table

1. Start an SSH session, connecting to the IP address of the machine.

        ssh -l demoadmin w.x.y.z

1. Clean up by deleting all resources in resource group <code>vm-demo-group</group>.

        az group delete --name vm-demo-group
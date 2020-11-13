---
layout: page
---
# Provision Linux VM using Azure CLI (Quick Version)

1. Open command prompt or PowerShell terminal

2. Login to the account and set the account subcription.

        az login 

        az account list --output table

        az account set --subscription "<subscription name>"

1. Create a resource group <code>vm-demo-group</code> to <code>uksouth</code> location to contain all resources created.

        az group create `
            --name "vm-demo-group" `
            --location "uksouth"

        az group list --output table 


1. Create the virtual machine

        az vm create `
            --resource-group "vm-demo-group" `
            --name "vm-demo-linux-1" `
            --image "rhel" `
            --size "Standard_B1S" `
            --admin-username "demoadmin" `
            --authentication-type "ssh" `
            --generate-ssh-keys

    This creates a RedHat linux virtual machine and all its dependent resources, including
    * Virtual Network
    * Subnet
    * Network Interface Card with
        * Network Security Group
        * Public IP Address
    * Storage Volume
    * SSH key pairs in ~/.ssh/ on your local machine (if none exist)

1. Clean up

         az group delete --name vm-demo-group
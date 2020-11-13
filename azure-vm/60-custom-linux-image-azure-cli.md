---
layout: page
---
# Create custom Linux image using Azure CLI

1. Open command line or Powershell, login to Azure and set account subscription.

        az login

        az account set --subscription "Personal"

1. Create an rhel virtual machine, update.

        az vm create `
            --resource-group "img-demo-rg" `
            --name "img-demo-linux-1" `
            --image "rhel" `
            --size "Standard_B1S" `
            --admin-username "demoadmin" `
            --authentication-type "ssh" `
            --generate-ssh-keys

1. Login to the machine.

        ssh demoadmin@40.122.49.195

        yum -y updatea

1. Deprovision and logout.

        > sudo waagent -deprovision+user -force

        > exit

1. Deallocate the machine

        az vm deallocate `
            --resource-group 'img-demo-rg' `
            --name 'img-demo-linux-1'

1. Mark the machine as generalized

        az vm generalize --resource-group 'img-demo-rg' --name 'img-demo-linux-1'

1. Create a custom image.

        az image create 
            --resource-group 'img-demo-rg' `
            --name 'img-demo-linux-ci-1' `
            --source 'img-demo-linux-1'

    Defaults to LRS, add the --zone-resilient option for ZRS if supported in your region

az image list --output table

#create vm from custom image
az vm create `
    --resource-group 'img-demo-rg' `
    --location 'centralus' `
    --name 'img-demo-linux-1c' `
    --image 'img-demo-linux-ci-1' `
    --admin-username 'demoadmin' `
    --authentication-type 'ssh' `
    --ssh-key-value '.\img-demo-key.pub'

az vm list --show-details --output table

#this will fail as VM is generalised
az vm start --name 'img-demo-linux-1' --resource-group 'img-demo-rg'

#delete the deallocated vm
az vm delete --name 'img-demo-linux-1' --resource-group 'img-demo-rg'

az resource list `
    --resource-type=Microsoft.Compute/images `
    --output table

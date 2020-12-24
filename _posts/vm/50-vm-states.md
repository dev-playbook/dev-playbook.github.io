---
layout: page
---
# Virtual Machine State Commands

1. Get status of linux instance

        Get-AzVm -ResourceGroupName '<resource group name>' `
            -Name 'psdemo-linux-1a' -Status

1. Stop linux instance with a background job

        Get-AzVm -ResourceGroupName '<resource group name>' `
            -Name 'psdemo-linux-1a' -Status `
            | Stop-AzVm -StayProvisioned -Force -AsJob

1. De-allocate machine

        Get-AzVm -ResourceGroupName '<resource group name>' `
            -Name 'psdemo-linux-1a' -Status `
            | Stop-AzVm -Force -AsJob

1. Start virtual machine

        Start-AzVm -ResourceGroupName '<resource group name>' `
            -Name 'psdemo-linux-1a' `
            -AsJob

1. Remove virtual machine

        Get-AzVm -ResourceGroupName '<resource group name>' `
            -Name 'psdemo-linux-1a' -Status `
            | Remove-AzVm -Force -AsJob
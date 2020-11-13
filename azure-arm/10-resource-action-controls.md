---
layout: page
---

# Resource Action Controls

## Available Providers

View all locations

    Get-AzLocation | Format-Table Location, DisplayName -AutoSize

List resource providers that are registered for a given location

    Get-AzResourceProvider -Location "eastus" | Select ProviderNamespace

Count resource providers registered for each location

    Get-AzLocation | Select -ExpandProperty Location `
        | ForEach {
            $_, `
            (Get-AzResourceProvider -Location $_ | Measure | Select -ExpandProperty Count)
        }

List all resource providers available for a given location

    Get-AzResourceProvider -Location "eastus" -ListAvailable `
        | Format-Table ProviderNamespace, RegistrationState

List resource providers not registered for a given location

    Get-AzResourceProvider -Location "eastus" -ListAvailable `
        | Where { $_.RegistrationState -eq 'NotRegistered' } `
        | Format-Table ProviderNamespace, RegistrationState

You can browse to all the available resource provider in the azure portal thru the _Resource Explorer_, or thru the resources portal.

    https://resources.azure.com/

## Register

Register or Unregister a given provider

    Register-AzResourceProvider -ProviderNamespace {namespace}
    
    Unregister-AzResourceProvider -ProviderNamespace {namespace}

You can register or unresigter a provider thru the console by the following 

- Navigate to Subscriptions
- Select a subscription
- From the left hand pane, click Resource Providers 
- Search and select the provider
- Click Register or Unregister

In order to be able to register, user must be granted action <code>*/register/action</code>. You can add the action to an existing role as follows.

    $role = Get-AzRoleDefinition -Name "<role name>"

    $role.Actions.Add("*/register/action")

    Set-AzRoleDefinition -Role $role

## Provider Details

Get resource types available in compute resource provider

    Get-AzResourceProvider -ProviderNamespace Microsoft.Compute `
        | Sort {$_.ResourceTypes.ResourceTypeName } `
        | Format-Table ResourceTypes
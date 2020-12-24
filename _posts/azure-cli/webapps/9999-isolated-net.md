vnname=webapp-demo-vnet
vnsubnetname=webapp-demo-subnet
az network vnet create --name $vnname --subnet-name $vnsubnetname

{
  "newVNet": {
    "addressSpace": {
      "addressPrefixes": [
        "10.0.0.0/16"
      ]
    },
    "bgpCommunities": null,
    "ddosProtectionPlan": null,
    "dhcpOptions": {
      "dnsServers": []
    },
    "enableDdosProtection": false,
    "enableVmProtection": false,
    "etag": "W/\"afb585cf-ca97-48aa-9bcf-52ee0f8d7550\"",
    "id": "/subscriptions/de7844d4-5c4d-472a-a59e-668b59536dcb/resourceGroups/webapp-demo-rg/providers/Microsoft.Network/virtualNetworks/webapp-demo-vnet",
    "ipAllocations": null,
    "location": "uksouth",
    "name": "webapp-demo-vnet",
    "provisioningState": "Succeeded",
    "resourceGroup": "webapp-demo-rg",
    "resourceGuid": "0c03a8eb-bb0e-4c48-a2ea-1f128be3d504",
    "subnets": [
      {
        "addressPrefix": "10.0.0.0/24",
        "addressPrefixes": null,
        "delegations": [],
        "etag": "W/\"afb585cf-ca97-48aa-9bcf-52ee0f8d7550\"",
        "id": "/subscriptions/de7844d4-5c4d-472a-a59e-668b59536dcb/resourceGroups/webapp-demo-rg/providers/Microsoft.Network/virtualNetworks/webapp-demo-vnet/subnets/webapp-demo-subnet",
        "ipAllocations": null,
        "ipConfigurationProfiles": null,
        "ipConfigurations": null,
        "name": "webapp-demo-subnet",
        "natGateway": null,
        "networkSecurityGroup": null,
        "privateEndpointNetworkPolicies": "Enabled",
        "privateEndpoints": null,
        "privateLinkServiceNetworkPolicies": "Enabled",
        "provisioningState": "Succeeded",
        "purpose": null,
        "resourceGroup": "webapp-demo-rg",
        "resourceNavigationLinks": null,
        "routeTable": null,
        "serviceAssociationLinks": null,
        "serviceEndpointPolicies": null,
        "serviceEndpoints": null,
        "type": "Microsoft.Network/virtualNetworks/subnets"
      }
    ],
    "tags": {},
    "type": "Microsoft.Network/virtualNetworks",
    "virtualNetworkPeerings": []
  }
}

https://azure.microsoft.com/en-gb/blog/announcing-app-service-isolated-more-power-scale-and-ease-of-use/


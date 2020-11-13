---
layout: page
---
# Creating Azure Resource Manager Templates

### Template Extracts from Portal

You can extract the template of an existing resource thru the portal by the following procedure.

1. Navigate to the existing resource
1. From the left hand pane, select _Export Template_
1. Select _Template_ and _Parameters_ tab to view the scripts
1. Click _Download_

You can also extract templates during the process of creating the resource thru the portal. Simply click _Download a template for automation_ at the *Review + create* stage.

### Custom Templates from Portal

You can create templates from scratch from the portal. 

- Search 'template' 
- Select _Deploy from a custom template_.

From here, you can find and add resources, parameters, and so on.

You can also use a selection of templates in GitHub from search box. 

- Find a suitable template (e.g 101-vm-simple-rhel)
- Click _Edit Template_

 You can browse available templates thru the following

    https://azure.microsoft.com/en-gb/resources/templates/

    https://github.com/Azure/azure-quickstart-templates

## Visual Studio Code

You can edit templates from Visual Studio Code with some useful tools such as intellisence.

- Press _Ctrl-Shift-X_ to open Extensions Marketplace
- Search _Azure CLI Tools_ and click Install
- Search _Azure Resource Manager Tools_ and click Install

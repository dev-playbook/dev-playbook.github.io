1. Delete all resources created in the group, including the web app and app service.

    ```shell
    az group delete --yes
    ```
    > Alternatively, to delete just the web app and app service, and maintain the resource group.
    > ```
    > az webapp delete
    > ```
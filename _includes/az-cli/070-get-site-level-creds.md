{% if include.slot %}
1. Get the site-level credentials for deployment to the **{{ include.slot }} slot**.

    ```shell
    username=$(az webapp deployment list-publishing-credentials --slot ${{ include.slot }} --query publishingUserName | sed -e 's/["\r ]//g')
    echo $username

    password=$(az webapp deployment list-publishing-credentials --slot ${{ include.slot }} --query publishingPassword | sed -e 's/["\r ]//g')
    echo $password
    ```
{% else %}
1. Get the site-level credentials for deployment.

    ```shell
    username=$(az webapp deployment list-publishing-credentials --query publishingUserName | sed -e 's/["\r ]//g')
    echo $username

    password=$(az webapp deployment list-publishing-credentials --query publishingPassword | sed -e 's/["\r ]//g')
    echo $password
    ```
{% endif %}

    >Alternatively, you can use <u>user-level credentials</u> directly tied to your Microsoft Account. This is global to all your Azure Web Apps and you only need to set this once. However, the <u>username has to be globally unique to all accounts in Azure</u>. You create or reset the user credentials by executing the following with the appropriate _{username}_ and _{password}_.
    >```
    >az webapp deployment user set --user-name '{username}' --password '{password}'
    >```
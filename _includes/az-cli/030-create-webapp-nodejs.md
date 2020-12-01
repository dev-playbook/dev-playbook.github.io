1. Create a web app with arguments including service plan, name and NodeJs runtime.
    
    ```shell
    appname="webapp-demo-app-$RANDOM"
    az webapp create --name $appname --plan $planname --runtime "node|12-lts" --verbose
    
    az configure --defaults web=$appname
    az configure --list-defaults --output table
    ```
    Results should include details of the new web app, indicating a successful creation.

    The name is randomised to ensure a unique hostname (i.e {name}.azurewebsites.net).

    Also, defaults for _web_ has been added to Azure cli. From here on, subsequent `az` commands will omit arguments to <code>--name</code> (of web app).
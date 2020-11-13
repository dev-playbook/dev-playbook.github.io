## github cli

1. Navigate to https://cli.github.com/ and install github cli

1. Login to github and follow instructions

    gh auth login

1. Set you preferred git protocol

    gh config set git_protocol { ssh | https }

#### Repository

1. Create bar repository

    gh repo create 'bar' --public --description 'Bar Repository' --confirm

1. Create a new public git hub repository under the current folder

    mkdir fooFolder

    cd .\fooFolder

    git init

    git config user.name 'foo'

    git config user.email 'foo@bar.qux'

    git commit -m 'foo'

    gh repo create --public --description 'Foo Repository' --confirm

    git push --set-upstream origin master
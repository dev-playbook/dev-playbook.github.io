# Initialize GitHub repository using SSH key

## Pre-requisite

1. Get SSH public key on your local machine.

    cat ~/.ssh/id_rsa.pub

  If it does not exist, create a SSH key pair beforehand.

    ssh-keygen -m PEM -t rsa -b 4096

1. Add the SSH public key in https://github.com/settings/keys, and test the connection.

    ssh -vT git@github.com

1. Create a repository from git hub

1. Clone the remote repository with the appropriate _{user-name}_ and _{repository-name}_

    git clone git@github.com:{user-name}/{repository-name}.git
    
    cd {repository-name}

  Or initialize new a local repository and add its remote origin.

    mkdir {repository-name}

    cd {repository-name}

    git init

    git remote add origin git@github.com:dev-playbook/foo.git

1. Set the _{username}_ and _{email}_ to the local repository

    git config --local user.name {username}

    git config --local user.email {email}

1. Do the first commit

    echo '' | Out-File README.md -Encoding UTF8

    git add README.md

    git commit -m 'first commit'

1. Push the changes

    git push --set-upstream origin master
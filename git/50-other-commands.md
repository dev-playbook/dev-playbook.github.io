# Other Commands

Remove untracked files including directories

    git clean -fd.

Remove untracked files including ignored files

    git clean -fX.

Remove untracked files including ignored and non-ignored files

    git clean -fx.

Show commit logs

    git log 
    
    git log -1  # last commit
    
    git log -2  # last two commits

    git log --graph --decorate --oneline 

Provide content or type and size information for repository objects

    git cat-file -p {commit-id} 

Get content of HEAD file

    cat .git/HEAD 

Show current local config

    cat .git/config

    git config --local -l

Show config value by name
  
    git config --local user.name

    git config --global user.name

Show remote repositories

    git remote -v 

Remove remote repository "origin" 
  
    git remote remove origin  
  
get difference between working area and index  
  
    git diff 

Show difference between index and local repository  
  
    git diff --cached
# Commit / Reset / Rebase

Show working tree status

    git status  

Add changes to index  
  
    git add .\apple_pie.txt

    git add * 

Commit changes to the repository with description

    git commit -m "Add more apples"  

Show changes in commit
  
    git show 500132

Revert index to HEAD
  
    git reset HEAD

Revert working area and index to HEAD 
  
    git reset --hard HEAD

Revert index to some-commit
  
    git reset --hard {commit-id}

Revert file in index to HEAD

    git reset HEAD {file-name}

Revert file to head

    git checkout HEAD {file-name}

Edit log history

    git rebase -interactive origin/master

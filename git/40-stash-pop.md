# Stash / Pop

Store changes to stash (include untracked changes)

    git stash --include-untracked

List stash

    git stash list

Show stash content

    git stash show {stash-id}

Apply stash

    git stash pop

    git stash pop "stash@{0}"

Apply and remove stash

    git stash pop

    git stash pop "stash@{0}"
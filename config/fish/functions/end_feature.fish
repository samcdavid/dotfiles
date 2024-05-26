function end_feature --wraps='git branch' --description 'update main branch, delete specified branch, and prune origin'
    git checkout main || git checkout master
    git pull origin main || git pull origin master
    git branch -D $argv
    git remote prune origin
end

function end_feature --wraps='git branch' --description 'update main branch, delete specified branch, and prune origin'
    # Remove worktree if one exists for this branch
    set -l wt_path (git worktree list --porcelain | while read -l line
        if string match -q "worktree *" $line
            set -f current_path (string replace "worktree " "" $line)
        else if test "$line" = "branch refs/heads/$argv[1]"
            echo $current_path
            break
        end
    end)

    if test -n "$wt_path"
        git worktree remove --force $wt_path
    end

    git checkout main || git checkout master
    git pull origin main || git pull origin master
    git branch -D $argv
    git remote prune origin
end

function new_worktree --wraps='git worktree add' --description 'add a sibling worktree on a new branch'
    if test (count $argv) -ne 2
        echo "usage: new_worktree <worktree_name> <branch_name>" >&2
        return 1
    end

    git -C .. worktree add $argv[1] -b $argv[2]
end

function new_worktree --wraps='git worktree add' --description 'add a sibling worktree on a new branch'
    if test (count $argv) -ne 2
        echo "usage: new_worktree <worktree_name> <branch_name>" >&2
        return 1
    end

    git -C .. worktree add $argv[1] -b $argv[2]
    or return $status

    set -l wt_root (cd .. && pwd)

    set -l setup_script "$wt_root/bin/setup-worktree-symlinks"
    if test -x "$setup_script"
        "$setup_script" $argv[1]
    end

    set -l copy_script "$wt_root/bin/copy-worktree-deps"
    if test -x "$copy_script"
        "$copy_script" $argv[1]
    end
end

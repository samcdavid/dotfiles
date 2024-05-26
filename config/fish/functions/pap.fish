function pap --wraps='pull && git fetch && git remote prune origin' --description 'alias pap=pull && git fetch && git remote prune origin'
  pull && git fetch && git remote prune origin $argv
        
end

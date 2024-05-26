function gc --wraps='git commit -S -v' --description 'alias gc=git commit -S -v'
  git commit -S -v $argv
        
end

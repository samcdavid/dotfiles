function shove --wraps='git push --force-with-lease --tags origin' --description 'alias shove=git push --force-with-lease --tags origin'
  git push --force-with-lease --tags origin $argv
        
end

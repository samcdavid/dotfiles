function push --wraps='git push --tags origin' --description 'alias push=git push --tags origin'
  git push --tags origin $argv
        
end

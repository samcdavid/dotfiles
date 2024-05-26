function rm_docker --wraps='docker rm $(docker ps -aq)' --description 'alias rm_docker=docker rm $(docker ps -aq)'
  docker rm $(docker ps -aq) $argv
        
end

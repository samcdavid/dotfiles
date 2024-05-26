function stop_docker --wraps='docker stop $(docker ps -aq)' --description 'alias stop_docker=docker stop $(docker ps -aq)'
  docker stop $(docker ps -aq) $argv
        
end

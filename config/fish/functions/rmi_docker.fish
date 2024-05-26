function rmi_docker --wraps='docker rmi $(docker images -aq)' --description 'alias rmi_docker=docker rmi $(docker images -aq)'
  docker rmi $(docker images -aq) $argv
        
end

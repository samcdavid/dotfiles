function pg_init --wraps='createuser -s postgres' --description 'alias pg_init=createuser -s postgres'
  createuser -s postgres $argv
        
end

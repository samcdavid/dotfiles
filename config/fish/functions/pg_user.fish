function pg_user --wraps='createuser -s postgres' --description 'alias pg_user=createuser -s postgres'
  createuser -s postgres $argv
        
end

function pg_stop --wraps='pg_ctl stop' --description 'alias pg_stop=pg_ctl stop'
  pg_ctl stop $argv
        
end

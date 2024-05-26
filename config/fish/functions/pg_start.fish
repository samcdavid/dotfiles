function pg_start --wraps='pg_start=pg_ctl -l /dev/null start' --description 'alias pg_start pg_start=pg_ctl -l /dev/null start'
  pg_start=pg_ctl -l /dev/null start $argv
        
end

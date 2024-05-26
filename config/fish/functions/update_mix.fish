function update_mix --wraps='mix do deps.get, deps.compile, compile && MIX_ENV=test mix do deps.compile, compile' --description 'alias update_mix=mix do deps.get, deps.compile, compile && MIX_ENV=test mix do deps.compile, compile'
  mix do deps.get, deps.compile, compile && MIX_ENV=test mix do deps.compile, compile $argv
        
end

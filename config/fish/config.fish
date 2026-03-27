if status is-interactive
    # Use Fish's built-in vi mode
    set -g fish_key_bindings fish_vi_key_bindings
    # ASDF configuration code
    if test -z $ASDF_DATA_DIR
        set _asdf_shims "$HOME/.asdf/shims"
    else
        set _asdf_shims "$ASDF_DATA_DIR/shims"
    end

    # Do not use fish_add_path (added in Fish 3.2) because it
    # potentially changes the order of items in PATH
    if not contains $_asdf_shims $PATH
        set -gx --prepend PATH $_asdf_shims
    end
    set --erase _asdf_shims
end

fish_add_path /opt/homebrew/opt/ffmpeg@6/bin
fish_add_path $HOME/.local/bin

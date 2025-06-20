if status is-interactive
    # Commands to run in interactive sessions can go here
end

# asdf setup
set -x ASDF_DATA_DIR /Users/sam/.asdf
fish_add_path $ASDF_DATA_DIR/shims
source /usr/local/Cellar/asdf/0.18.0/libexec/asdf.fish

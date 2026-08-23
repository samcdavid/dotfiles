function update_nvim --description 'Reinstall Neovim from the latest GitHub release (Linux only)'
    if test (uname -s) != Linux
        echo "update_nvim is Linux-only — on Mac, Neovim comes from Homebrew, so run: brew upgrade neovim"
        return 1
    end

    set -l tag (curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | jq -r .tag_name)
    if test -z "$tag" -o "$tag" = null
        echo "Could not determine the latest Neovim release tag."
        return 1
    end

    echo "Installing Neovim $tag..."
    rm -rf ~/.local/nvim
    mkdir -p ~/.local/nvim
    curl -fsSL "https://github.com/neovim/neovim/releases/download/$tag/nvim-linux-x86_64.tar.gz" \
        | tar -xz --strip-components=1 -C ~/.local/nvim
    ln -sf ~/.local/nvim/bin/nvim ~/.local/bin/nvim

    echo "Neovim updated:" (nvim --version | head -1)
end

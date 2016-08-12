cd ~/.vim/bundle

# Install plugins
git clone --depth=1 https://github.com/scrooloose/syntastic.git
git clone https://github.com/Valloric/YouCompleteMe.git
git clone https://github.com/airblade/vim-gitgutter.git
git clone https://github.com/bling/vim-airline-themes.git
git clone https://github.com/bling/vim-airline.git
git clone https://github.com/bronson/vim-trailing-whitespace.git
git clone https://github.com/digitaltoad/vim-pug.git
git clone https://github.com/elixir-lang/vim-elixir.git
git clone https://github.com/jelera/vim-javascript-syntax.git
git clone https://github.com/kien/ctrlp.vim.git
git clone https://github.com/leafgarland/typescript-vim.git
git clone https://github.com/mxw/vim-jsx.git
git clone https://github.com/pangloss/vim-javascript.git
git clone https://github.com/rizzatti/dash.vim.git
git clone https://github.com/slim-template/vim-slim.git
git clone https://github.com/tpope/vim-sensible.git
git clone https://github.com/tpope/vim-surround.git
git clone https://github.com/tpope/vim-vinegar.git
git clone https://github.com/vim-ruby/vim-ruby.git

# Plugin specific setup
cd ~/.vim/bundle/YouCompleteMe
git submodule update --init --recursive
./install.py --clang-completer

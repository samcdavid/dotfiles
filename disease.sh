cd ~/.vim/bundle

# Install plugins
git clone --depth=1 https://github.com/scrooloose/syntastic.git
cd ~/.vim/bundle/syntastic
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/Valloric/YouCompleteMe.git
cd ~/.vim/bundle/YouCompleteMe
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/airblade/vim-gitgutter.git
cd ~/.vim/bundle/vim-gitgutter
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/bling/vim-airline.git
cd ~/.vim/bundle/vim-airline
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/bronson/vim-trailing-whitespace.git
cd ~/.vim/bundle/vim-trailing-whitespace
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/digitaltoad/vim-pug.git
cd ~/.vim/bundle/vim-pug
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/editorconfig/editorconfig-vim.git
cd ~/.vim/bundle/editorconfig-vim
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/elixir-lang/vim-elixir.git
cd ~/.vim/bundle/lang/vim-elixir
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/hhsnopek/vim-sugarss.git
cd ~/.vim/bundle/vim-sugarss
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/jelera/vim-javascript-syntax.git
cd ~/.vim/bundle/vim-javascript-syntax
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/kien/ctrlp.vim.git
cd ~/.vim/bundle/ctrlp
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/leafgarland/typescript-vim.git
cd ~/.vim/bundle/typescript-vim
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/mxw/vim-jsx.git
cd ~/.vim/bundle/vim-jsx
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/pangloss/vim-javascript.git
cd ~/.vim/bundle/vim-javascript
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/rizzatti/dash.vim.git
cd ~/.vim/bundle/dash
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/slim-template/vim-slim.git
cd ~/.vim/bundle/template/vim-slim
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/tpope/vim-bundler.git
cd ~/.vim/bundle/vim-bundler
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/tpope/vim-endwise.git
cd ~/.vim/bundle/vim-endwise
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/tpope/vim-fugitive.git
cd ~/.vim/bundle/vim-fugitive
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/tpope/vim-rails.git
cd ~/.vim/bundle/vim-rails
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/tpope/vim-sensible.git
cd ~/.vim/bundle/vim-sensible
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/tpope/vim-surround.git
cd ~/.vim/bundle/vim-surround
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/tpope/vim-vinegar.git
cd ~/.vim/bundle/vim-vinegar
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/vim-airline/vim-airline-themes
cd ~/.vim/bundle/vim-airline-themes
git pull origin master
cd ~/.vim/bundle

git clone https://github.com/vim-ruby/vim-ruby.git
cd ~/.vim/bundle/ruby/vim-ruby
git pull origin master
cd ~/.vim/bundle

# Plugin specific setup
cd ~/.vim/bundle/YouCompleteMe
git submodule update --init --recursive
./install.py --clang-completer

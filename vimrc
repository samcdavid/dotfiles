filetype off
execute pathogen#infect()
filetype plugin indent on

set nocompatible              " be iMproved, required
syntax on
set guifont=Hack\ 12
set autoindent
set expandtab
set laststatus=2
set noswapfile
set nobackup
set nowb
set number
set splitbelow
set splitright
set tabstop=2 shiftwidth=2 softtabstop=2
colorscheme SlateDark

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'vim-ruby/vim-ruby'
Plugin 'rizzatti/dash.vim'
Plugin 'slim-template/vim-slim'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'kien/ctrlp.vim'
Plugin 'flazz/vim-colorschemes'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1
autocmd Filetype gitcommit setlocal spell textwidth=72

" Pathogen Installed Plugins
" cd ~/.vim/bundle
" git clone git://github.com/digitaltoad/vim-jade.git
" git clone git://github.com/tpope/vim-sensible.git
" git clone git://github.com/tpope/vim-fugitive.git
" git clone git://github.com/airblade/vim-gitgutter.git
" git clone git://github.com/bling/vim-airline.git
" git clone git://github.com/scroolose/syntastic.git
" git clone https://github.com/scrooloose/nerdtree.git

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.coffee :call DeleteTrailingWS()
autocmd BufWrite *.rb :call DeleteTrailingWS()

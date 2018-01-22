set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

let mapleader = "_"
inoremap jj <esc>
nmap <Leader><Space> :noh<CR>
nmap <Leader>: :Neoformat<CR>

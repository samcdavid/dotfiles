filetype off
execute pathogen#infect()
filetype plugin indent on

colo seoul256
let g:airline_powerline_fonts = 1
let g:airline_theme = 'deus'
let g:airline_section_c = '%t'
let g:airline_section_x = ''
let g:airline_section_y = ''

set nocompatible              " be iMproved, required
syntax on
set t_Co=256
set guifont=Hack\ 12
set autoindent
set expandtab
set laststatus=2
set noswapfile
set nobackup
set nowb
set number rnu
set splitbelow
set splitright
set tabstop=2 shiftwidth=2 softtabstop=2
set mouse=a
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set background=dark

let mapleader = "_"
inoremap jj <esc>
nmap <Leader><Space> :noh<CR>
nmap <Leader>: :FZF<CR>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1
autocmd Filetype gitcommit setlocal spell textwidth=72

let g:ale_fixers = {
\ 'typescript': ['tslint'],
\}

let g:airline#extensions#ale#enabled = 1

let g:jsx_ext_required = 0

func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite * :call DeleteTrailingWS()

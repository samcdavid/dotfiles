filetype off
execute pathogen#infect()
filetype plugin indent on

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

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1
autocmd Filetype gitcommit setlocal spell textwidth=72

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:neoformat_elixir_mix_format = {
  \ 'exe': 'mix',
  \ 'args': ['format', '-'],
  \ 'stdin': 1
  \ }

let g:neoformat_enabled_elixir = ['mix_format']

let g:airline_powerline_fonts = 1

let g:jsx_ext_required = 0

func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite * :call DeleteTrailingWS()

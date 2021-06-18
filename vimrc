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
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set background=dark
set hidden
set runtimepath+=~/.vim/bundle/LanguageClient-neovim

let mapleader = "_"
inoremap jj <esc>
nmap <Leader><Space> :noh<CR>
nmap <Leader>: :FZF<CR>
nmap <Leader>f :ALEFix<CR>

" These mappings make it easier to move between splits
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1
autocmd Filetype gitcommit setlocal spell textwidth=72

colo seoul256
let g:airline_powerline_fonts = 1
let g:airline_theme = 'deus'
let g:airline_section_c = '%t'
let g:airline_section_x = ''
let g:airline_section_y = ''

let g:ale_fixers = {
\ 'typescript': ['tslint'],
\}

let g:airline#extensions#ale#enabled = 1

let g:jsx_ext_required = 0

let g:deoplete#enable_at_startup = 1

let g:LanguageClient_settingsPath='~/.neovim-languageclient-settings.json'
let g:LanguageClient_serverCommands = {
    \ 'elixir': ['~/Developer/elixir-ls/rel/language_server.sh'],
    \ 'python': ['~/.asdf/shims/pyls'],
    \ 'ruby': ['~/.asdf/shims/solargraph', 'stdio'],
    \ }

" Mappings for the language client
nnoremap <Leader>5 :call LanguageClient_contextMenu()<CR>
nnoremap <silent>K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent>gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <Leader>2 :call LanguageClient#textDocument_rename()<CR>

func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite * :call DeleteTrailingWS()

syntax on
filetype indent on
set number relativenumber
set nowrap

set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

set virtualedit=block
set clipboard=unnamedplus " only works if vim is compiled with clipboard support

set ignorecase
set termguicolors

set scrolloff=999

set splitbelow
set splitright

set background=dark
let g:solarized_termcolors=256
let g:solarized_termtrans=1

set hidden " switch buffers without saving first (default in nvim)

let mapleader = " "
nnoremap <leader>pv :Ex<CR>
nnoremap <leader>pb :ls<CR>:b<Space>
nnoremap <leader>bd :bdelete<CR>
nnoremap <S-h> :bprevious<CR>
nnoremap <S-l> :bnext<CR>

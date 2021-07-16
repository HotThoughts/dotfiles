call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'dag/vim-fish'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

call plug#end()


set number
set textwidth=88
set wrap linebreak
set shiftwidth=2
set autoindent
set smartindent
set backspace=indent,eol,start
set autochdir
set rtp+=/usr/local/opt/fzf

" Dracula theme
syntax enable
colorscheme dracula
highlight Normal ctermbg=None "Use terminal backgroud 

" Nerd Tree
nmap <C-n> :NERDTreeToggle<CR>

" Lightline
let g:lightline = { 'colorscheme': 'darcula'}
set laststatus=2
set noshowmode

" Auto Plug-in Installation
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


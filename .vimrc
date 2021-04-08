syntax on
set number
set shiftwidth=2
set autoindent
set smartindent

call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

call plug#end()

map <C-n> :NERDTreeToggle<CR>

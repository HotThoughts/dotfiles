syntax on
set number

call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

call plug#end()

map <C-n> :NERDTreeToggle<CR>

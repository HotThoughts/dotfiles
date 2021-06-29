syntax on
set number
set shiftwidth=2
set autoindent
set smartindent
set rtp+=/usr/local/opt/fzf

call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'dag/vim-fish'

call plug#end()

map <C-n> :NERDTreeToggle<CR>

set number
set mouse=a
syntax enable
set showcmd
set encoding=utf-8
set showmatch

set autoindent
set smartindent

" === BÚSQUEDA ===
set ignorecase          " Ignorar mayúsculas al buscar
set smartcase           " No ignorar si hay mayúsculas
set incsearch           " Búsqueda incremental
set hlsearch            " Resaltar resultados


" === CONFIGURACIONES BÁSICAS ===
set relativenumber      " Números relativos (muy útil!)
set tabstop=4           " Tabs de 4 espacios
set shiftwidth=4        " Indentación de 4 espacios
set expandtab           " Convierte tabs en espacios
set smartindent         " Indentación inteligente
set wrap                " Ajuste de líneas largas
set clipboard=unnamedplus " Compartir portapapeles con sistema

" Quitar resaltado de búsqueda con ESC doble
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

call plug#begin()
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'nvim-tree/nvim-web-devicons'
  Plug 'navarasu/onedark.nvim'
  Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
  Plug 'rust-lang/rust.vim'


  Plug 'preservim/nerdtree'  
  Plug 'jiangmiao/auto-pairs'            " Auto-cerrar brackets
  Plug 'tpope/vim-commentary'            " Comentar código fácil
  Plug 'ctrlpvim/ctrlp.vim'

call plug#end()

" Usar un autocmd para ejecutar la configuración de lualine después de que todos los complementos estén listos

lua << END

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'material'
  }
}

require('onedark').setup {
	style = "dark",
	transparent = true,
}

require('onedark').load()


require("nvim-web-devicons").setup({
  disable_netrw = false,
  hijack_netrw = false,
  hijack_cursor = false,
  actions = {
    open_file = {
      quit_on_open = false,
    }
  }
})

END

" nota: the leader key inst working yet, as long as I remember

let mapleader = " "    

nnoremap ; :
vnoremap ; :

" === NERDTREE ===
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" === CTRLP ===
let g:ctrlp_map = '<C-p>'
let g:ctrlp_cmd = 'CtrlP'

" === COMENTARY ===
" Comentar con Ctrl+/
nnoremap <C-/> :Commentary<CR>
vnoremap <C-/> :Commentary<CR>


" === ATAJOS BÁSICOS ===
" Guardar archivo
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a

" Salir
nnoremap <C-q> :q<CR>

" Guardar y salir
nnoremap <C-x> :wq<CR>

" Recargar configuración
nnoremap <leader>r :source ~/.config/nvim/init.vim<CR>

" === MOVIMIENTO MEJORADO ===
" Desplazamiento suave
nnoremap <C-j> 5j
nnoremap <C-k> 5k

" Mover líneas seleccionadas arriba/abajo
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" === BÚSQUEDA ===
" Buscar y reemplazar en todo el archivo
nnoremap <leader>s :%s//g<Left><Left>

" Buscar la palabra bajo el cursor
nnoremap <leader>f /<C-r><C-w><CR>

" === VENTANAS ===
" Moverse entre ventanas con Ctrl + dirección
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Crear nuevas ventanas
nnoremap <leader>v :vsplit<CR>
nnoremap <leader>h :split<CR>


" === CONFIGURACIÓN COC.NVIM ===

" Usar TAB para autocompletar
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Usar Enter para seleccionar item del autocompletado
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Función para verificar backspace
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Atajos útiles
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> <leader>rn <Plug>(coc-rename)



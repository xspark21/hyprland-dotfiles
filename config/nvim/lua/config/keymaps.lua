local map = vim.keymap.set
-- NERDTREE
map("n", "<C-n>", ":NERDTreeToggle<CR>")
map("n", "<C-f>", ":NERDTreeFind<CR>")

-- CTRLP
vim.g.ctrlp_map = "<C-p>"
vim.g.ctrlp_cmd = "CtrlP"

-- COMMENTARY
map("n", "<C-/>", ":Commentary<CR>")
map("v", "<C-/>", ":Commentary<CR>")

map("n", "<Esc><Esc>", ":nohlsearch<CR>", { silent = true })

map("n", ";", ":")
map("v", ";", ":")

map("n", "<C-s>", ":w<CR>")
map("i", "<C-s>", "<Esc>:w<CR>a")
map("n", "<C-q>", ":q<CR>")
map("n", "<C-x>", ":wq<CR>")

map("n", "<leader>r", ":source $MYVIMRC<CR>")

map("n", "<C-j>", "5j")
map("n", "<C-k>", "5k")

map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

map("n", "<leader>v", ":vsplit<CR>")
map("n", "<leader>h", ":split<CR>")

require("lazy").setup({

  -- ===== UI =====
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
        },
      })
    end,
  },

  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ===== THEMES =====
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "dark",
        transparent = true,
      })
      require("onedark").load()
    end,
  },

  { "catppuccin/nvim", name = "catppuccin", lazy = true },

  -- ===== LSP / AUTOCOMPLETE =====
  {
    "neoclide/coc.nvim",
    branch = "release",
    event = "InsertEnter",
  },

  -- ===== FILES =====
  {
    "preservim/nerdtree",
    cmd = { "NERDTreeToggle", "NERDTreeFind" },
  },

  { "ctrlpvim/ctrlp.vim", cmd = "CtrlP" },

  -- ===== DEV =====
  { "rust-lang/rust.vim", ft = "rust" },

  { "jiangmiao/auto-pairs", event = "InsertEnter" },

  { "tpope/vim-commentary", keys = { "gc", "<C-/>" } },

}, {
  checker = { enabled = false },
})

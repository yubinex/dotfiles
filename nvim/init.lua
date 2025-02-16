-- Set leader key
vim.g.mapleader = " "

-- Install Lazy.nvim (Plugin Manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
    -- LSP Support (Language Servers)
    { "neovim/nvim-lspconfig" },

    -- Autocompletion (IntelliSense)
    { "hrsh7th/nvim-cmp",
      dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "L3MON4D3/LuaSnip",
          "saadparwaiz1/cmp_luasnip",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path"
      }
    },

    -- Treesitter (Better Syntax Highlighting)
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    -- File Explorer
    { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

    -- Fuzzy Finder (Find files, grep, etc.)
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

    -- Autoformat on save
    { "stevearc/conform.nvim" },

    -- Bracket Auto-closing
    { "windwp/nvim-autopairs" },

    -- Gruvbox Theme
    { "morhetz/gruvbox" },

    -- Discord Rich Presence
    { "andweeb/presence.nvim" }
})

-- LSP Configuration
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Python LSP (Auto-detect venv)
lspconfig.pyright.setup({
    capabilities = capabilities,
    on_init = function(client)
        local venv_path = os.getenv("VIRTUAL_ENV")
        if venv_path then
            client.config.settings.python.pythonPath = venv_path .. "/bin/python"
        else
            client.config.settings.python.pythonPath = vim.fn.exepath("python3")
        end
    end
})

-- Go LSP
lspconfig.gopls.setup({
    capabilities = capabilities
})

-- Treesitter Configuration
require("nvim-treesitter.configs").setup({
    ensure_installed = { "python", "go", "lua" },
    highlight = { enable = true }
})

-- Autoformat on save (Python & Go)
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.py", "*.go" },
    callback = function()
        require("conform").format()
    end,
})

-- Setup nvim-cmp (IntelliSense)
local cmp = require("cmp")
cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item()
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" }
    })
})

-- Enable Auto-pairs (Bracket auto-closing)
require("nvim-autopairs").setup({})

-- Setup nvim-tree (File Explorer)
require("nvim-tree").setup({
    update_focused_file = {
        enable = true,
        update_root = true,
    },
    actions = {
        open_file = {
            quit_on_open = true, -- Automatically close the tree when opening a file
        },
    },
})

-- File Explorer Keybind
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })

-- Telescope (Find files & Grep)
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { silent = true })

-- Set Gruvbox Theme
vim.o.background = "dark" -- Use Gruvbox dark theme
vim.cmd("colorscheme gruvbox")

-- Gruvbox Customization
vim.g.gruvbox_contrast_dark = "hard"  -- Options: "soft", "medium", "hard"
vim.g.gruvbox_invert_selection = 0    -- Disable inverted selection
vim.g.gruvbox_italic = 1              -- Enable italics

-- Enable Line Numbers
vim.opt.number = true  -- Absolute line numbers
vim.opt.relativenumber = true  -- Relative line numbers

-- Discord Rich Presence
require("presence").setup({
    auto_update = true,      -- Auto-update Discord status
    neovim_image_text = "How do I close Neovim...",  -- Custom hover text
    main_image = "neovim",   -- Logo: "neovim", "file", or "none"

    -- Rich presence text
    editing_text = "Editing %s",  -- Shows "Editing [filename]"
    file_explorer_text = "Browsing files...",
    git_commit_text = "Committing changes...",
    plugin_manager_text = "Managing plugins...",
    reading_text = "Reading %s",
    workspace_text = "Working on %s",
    line_number_text = "Line %s/%s",

    -- Buttons
    show_time = true,  -- Show elapsed time
})

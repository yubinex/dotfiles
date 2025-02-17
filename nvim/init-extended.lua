-- Set leader key
vim.g.mapleader = " "

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

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
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp", dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path"
    }},
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "stevearc/conform.nvim" },
    { "windwp/nvim-autopairs" },
    { "morhetz/gruvbox" },
    { "andweeb/presence.nvim" }
})

-- LSP Configuration
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Python LSP
lspconfig.pyright.setup({ capabilities = capabilities })

-- Go LSP
lspconfig.gopls.setup({
    capabilities = capabilities,
    settings = {
        gopls = {
            experimentalPostfixCompletions = true,
            analyses = { unusedparams = true, shadow = true },
            staticcheck = true,
            templateExtensions = { "tmpl", "tpl", "html" },
        },
    }
})

-- TypeScript & JavaScript LSP (Fixed tsserver deprecation!)
lspconfig.ts_ls.setup({
    cmd = { "typescript-language-server", "--stdio" },
    capabilities = capabilities,
    filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
    settings = {
        javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
        typescript = { inlayHints = { includeInlayParameterNameHints = "all" } },
    }
})

-- ESLint for JavaScript & TypeScript
lspconfig.eslint.setup({
    capabilities = capabilities,
    filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    settings = {
        format = true,
        lintTask = { enable = true },
    }
})

-- HTML & CSS LSP
lspconfig.html.setup({ capabilities = capabilities })
lspconfig.cssls.setup({ capabilities = capabilities })

-- Treesitter Configuration
require("nvim-treesitter.configs").setup({
    ensure_installed = { "python", "go", "lua", "html", "css", "javascript", "typescript", "tsx" },
    highlight = { enable = true },
    additional_vim_regex_highlighting = { "gohtmltmpl" },
})

-- Enable Filetype Detection for Go Templates
vim.filetype.add({
    pattern = {
        [".*%.tmpl"] = "gohtmltmpl",
        [".*%.tpl"] = "gohtmltmpl",
    },
})

-- Detect Go templates inside .html files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.html" },
    callback = function()
        if vim.fn.search("{{", "nw") > 0 then
            vim.bo.filetype = "gohtmltmpl"
        end
    end,
})

-- Autoformat on save
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.py", "*.go", "*.tmpl", "*.tpl", "*.html", "*.js", "*.ts", "*.jsx", "*.tsx" },
    callback = function()
        vim.cmd("%!prettier --stdin-filepath %")
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
local npairs = require("nvim-autopairs")
npairs.setup({ check_ts = true })
local Rule = require("nvim-autopairs.rule")
npairs.add_rule(Rule("{{", "}}"):with_pair(function()
    return vim.bo.filetype == "gohtmltmpl"
end))

-- Setup nvim-tree (File Explorer)
require("nvim-tree").setup({
    update_focused_file = { enable = true, update_root = true },
    actions = { open_file = { quit_on_open = true } },
})

-- File Explorer Keybind
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })

-- Telescope (Find files & Grep)
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { silent = true })

-- Set Gruvbox Theme
vim.o.background = "dark"
vim.cmd("colorscheme gruvbox")

vim.g.gruvbox_contrast_dark = "hard"
vim.g.gruvbox_invert_selection = 0
vim.g.gruvbox_italic = 1

-- Enable Line Numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Discord Rich Presence
require("presence").setup({
    auto_update = true,
    neovim_image_text = "How do I close Neovim...",
    main_image = "neovim",
    editing_text = "Editing %s",
    file_explorer_text = "Browsing files...",
    git_commit_text = "Committing changes...",
    plugin_manager_text = "Managing plugins...",
    reading_text = "Reading %s",
    workspace_text = "Working on %s",
    line_number_text = "Line %s/%s",
    show_time = true,
})

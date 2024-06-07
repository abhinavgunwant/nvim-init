set number relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set mouse=a
"set encoding=UTF-8

" Plug plugins!
call plug#begin()

"""" Language Plugins
" lspconfig
Plug 'neovim/nvim-lspconfig'

" completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

" dap
Plug 'mfussenegger/nvim-dap'

" Typescript
Plug 'leafgarland/typescript-vim'

" Rust
Plug 'rust-lang/rust.vim'
"Plug 'simrat39/rust-tools.nvim'

" Java
Plug 'mfussenegger/nvim-jdtls'

" nvim-treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" DB
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'

"""" Editor Utilities and themes

" NERDTree
Plug 'preservim/nerdtree'

" nerdfonts
Plug 'nvim-tree/nvim-web-devicons'

" lualine
Plug 'nvim-lualine/lualine.nvim'

" tab-bar
Plug 'romgrk/barbar.nvim'

" Nightfox theme
Plug 'EdenEast/nightfox.nvim'

" telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }

" Git
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'

" Games?
Plug 'ThePrimeagen/vim-be-good'

call plug#end()

" Set colorscheme
colorscheme duskfox

" Open .tsx files open as typescript file
au BufNewFile,BufRead *.ts setlocal filetype=typescript
au BufNewFile,BufRead *.tsx setlocal filetype=typescript.tsx

" LSP Configurations - see https://gist.github.com/mengwangk/570a6ceb8cd14e55f4d89ac865850418
:lua << EOF
    -- -------------------------------------------
    -- nvim-cmp
    -- -------------------------------------------
    local cmp = require'cmp'

    cmp.setup({
        snippet = {
            expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
            end,
        },
        window = {},
        mapping = cmp.mapping.preset.insert({
            ['<C-j>'] = cmp.mapping.scroll_docs(-4),
            ['<C-k>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-q>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
            { name = 'nvim_lsp' }, { name = 'vsnip' },
        }, {
            { name = 'buffer' },
        })
    })

    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = 'buffer' } }
    })

    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = 'path' }
        }, {
            { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
    })

    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- -------------------------------------------
    -- BarBar Config
    -- -------------------------------------------
    require('barbar').setup {
        icons = { filetype = { enabled = true } },
        animation = false,
        auto_hide = true,
        closeable = false,
    }

    -- -------------------------------------------
    -- LSP Config
    -- -------------------------------------------

    local nvim_lsp = require('lspconfig')

    local on_attach = function (client, bufnr)
        -- require('completion').on_attach()

        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        vim.diagnostic.config({
            virtual_text = {
                prefix = "->",
            },
            severity_sort = true,
            float = {
                source = "always",
            },
        })

        -- Mappings
        local opts = { noremap=true, silent=true }
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        -- buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        -- buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

        -- Set some keybinds conditional on server capabilities
        if client.server_capabilities.document_formatting then
            buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
        elseif client.server_capabilities.document_range_formatting then
            buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
        end

        -- Set some commands conditional on server capabilities
        if client.server_capabilities.document_highlight then
            -- Note: usage of `require('lspconfig').util.nvim_multiline_command [[` is depricated, so using:
            vim.api.nvim_exec([[
            :hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
            :hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
            :hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
            augroup lsp_document_highlight
                autocmd!
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
            augroup END
            ]], false)
        end
    end

    -- Set up lspconfig.
    -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
    -- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
      -- capabilities = capabilities
    -- }

    -- -------------------------------------------
    -- LSP: Add servers here...
    -- -------------------------------------------
    local servers = { 'rust_analyzer', 'tsserver' }

    for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities,
        }
    end

    -- -------------------------------------------
    -- Rust Tools
    -- -------------------------------------------
--    local rt = require("rust-tools")
--
--    rt.setup({
--      server = {
--        on_attach = function(_, bufnr)
--          -- Hover actions
--          vim.keymap.set("n", "gk", rt.hover_actions.hover_actions, { buffer = bufnr })
--          -- Code action groups
--          vim.keymap.set("n", "gj", rt.code_action_group.code_action_group, { buffer = bufnr })
--        end,
--      },
--    })
    -- -------------------------------------------
    -- NightFox Theme Config
    -- -------------------------------------------
    local nightfox = require("nightfox")
    nightfox.setup({
        options = {
            transparent = true,
        },
    })
    nightfox.load()

    -- -------------------------------------------
    -- LuaLine Config
    -- -------------------------------------------
    require('lualine').setup({
        disabled_filetypes = {
            statusline = {
                'NERD_tree',
            },
            winbar = {
                'NERD_tree',
            }
        },
    })

    -- -------------------------------------------
    -- Telescope Config
    -- -------------------------------------------
    local telescope = require('telescope')
    telescope.setup({
        pickers = {
            find_files = {
                file_ignore_patterns = {
                    "%.class",

                    -- for linux
                    ".git/", "node_modules/", "target/", "build/", "dist/",

                    -- for windows
                    ".git\\", "node_modules\\", "target\\", "build\\", "dist\\",
                }
            }
        }
    })

    -- -------------------------------------------
    -- Gitsigns
    -- -------------------------------------------
    require('gitsigns').setup()
EOF

" Additional key maps
:map <F3> :NERDTreeToggle<CR>

" BarBar shortcuts
noremap <silent> gt <Cmd>BufferNext<CR>
noremap <silent> gT <Cmd>BufferPrevious<CR>
noremap <silent> gc <Cmd>BufferClose<CR>
noremap <silent> gp <Cmd>BufferPin<CR>
noremap <silent> g1 <Cmd>BufferGoto 1<CR>
noremap <silent> g2 <Cmd>BufferGoto 2<CR>
noremap <silent> g3 <Cmd>BufferGoto 3<CR>
noremap <silent> g4 <Cmd>BufferGoto 4<CR>
noremap <silent> g5 <Cmd>BufferGoto 5<CR>
noremap <silent> g6 <Cmd>BufferGoto 6<CR>
noremap <silent> g7 <Cmd>BufferGoto 7<CR>
noremap <silent> g8 <Cmd>BufferGoto 8<CR>
noremap <silent> g9 <Cmd>BufferGoto 9<CR>
noremap <silent> g0 <Cmd>BufferLast<CR>
nnoremap <silent> <A-<> <Cmd>BufferMovePrevious<CR>
nnoremap <silent> <A->> <Cmd>BufferMoveNext<CR>

" LSP shortcuts
noremap <silent> ge <cmd>lua vim.diagnostic.open_float()<CR>" Opens errors in a floating screen
noremap <silent> K <Cmd>lua vim.lsp.buf.hover()<CR>

" Telescope shortcuts
nnoremap <silent>gf <Cmd>Telescope find_files<CR>
nnoremap <silent>gl <Cmd>Telescope live_grep<CR>
nnoremap <silent>gb <Cmd>Telescope buffers<CR>
nnoremap <silent>gh <Cmd>Telescope help_tags<CR>

" nvim-dap - for debugging
noremap <silent> <C-b> <cmd>lua require'dap'.toggle_breakpoint()<CR> " Set debug breakpoint
noremap <silent> <F8> <cmd>lua require'dap'.continue()<CR> " Continue debug execution
noremap <silent> <F10> <cmd>lua require'dap'.step_over()<CR> " Setp over
noremap <silent> <C-i> <cmd>lua require'dap'.repl.open()<CR> " Inspect

" Gitsigns
noremap <silent>gp <cmd>Gitsigns preview_hunk<CR>


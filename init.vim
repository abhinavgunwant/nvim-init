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
Plug 'nvim-lua/completion-nvim'


" COC
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
" COC Extensions
let g:coc_global_extensions = ['coc-tsserver', 'coc-tslint', 'coc-emmet', 'coc-css', 'coc-html', 'coc-json', 'coc-yank', 'coc-prettier']

Plug 'leafgarland/typescript-vim'
" Rust
Plug 'rust-lang/rust.vim'

"""" Editor Utilities and themes
" NERDTree
Plug 'preservim/nerdtree'
" Plug 'ryanoasis/vim-devicons'
"
" tab-bar
Plug 'nvim-tree/nvim-web-devicons'
"Plug 'ryanoasis/vim-devicons'
Plug 'romgrk/barbar.nvim'
" Nightfox theme
Plug 'EdenEast/nightfox.nvim'

call plug#end()

" Set colorscheme
colorscheme duskfox

" Open .tsx files open as typescript file
au BufNewFile,BufRead *.ts setlocal filetype=typescript
au BufNewFile,BufRead *.tsx setlocal filetype=typescript.tsx

" LSP Configurations - see https://gist.github.com/mengwangk/570a6ceb8cd14e55f4d89ac865850418
:lua << EOF
    local nvim_lsp = require('lspconfig')

    local on_attach = function (client, bufnr)
        require('completion').on_attach()

        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings
        local opts = { noremap=true, silent=true }
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

        -- Set some keybinds conditional on server capabilities
        if client.resolved_capabilities.document_formatting then
            buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
        elseif client.resolved_capabilities.document_range_formatting then
            buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
        end

        -- Set some commands conditional on server capabilities
        if client.resolved_capabilities.document_highlight then
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

    -- -------------------------------------------
    -- Add servers here...
    -- -------------------------------------------
    local servers = { 'rust_analyzer' }

    for _, lsp in ipairs(servers) do
        nvim_lsp[lsp].setup {
            on_attach = on_attach,
        }
    end
EOF

" Additional key maps
:map <F3> :NERDTreeToggle<CR>

" BarBar config
let bufferline = get(g:, 'bufferline', {})
let bufferline.icons = v:false
let bufferline.animation = v:false
let bufferline.auto_hide = v:true
let bufferline.closeable = v:false
noremap <silent> gt <Cmd>BufferNext<CR>
noremap <silent> gT <Cmd>BufferPrevious<CR>
noremap <silent> gc <Cmd>BufferClose<CR>
noremap <silent> gp <Cmd>BufferPin<CR>


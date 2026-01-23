return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'williamboman/mason.nvim', version = 'v1.*' },
    { 'williamboman/mason-lspconfig.nvim', version = 'v1.*' },
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    -- { 'pmizio/typescript-tools.nvim', opts = {} },
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {

      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            callback = vim.lsp.buf.clear_references,
          })
        end
      end,
    })

    local servers = {
      astro = {},
      biome = {},
      clangd = {},
      docker_compose_language_service = {},
      eslint = {},
      gopls = {},
      graphql = {},
      html = {},
      jqls = {},
      jsonls = {},
      lua_ls = {
        settings = {
          Lua = {
            runtime = {
              version = 'LuaJIT',
            },
            diagnostics = {
              globals = {
                'vim',
                'require',
              },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
            },
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
      mdx_analyzer = {},
      pyright = {},
      rust_analyzer = {},
      stylua = {},
      tailwindcss = {},
      terraformls = {},
      ts_ls = {},
      yamlls = {},
      zls = {},
    }
    local keys = vim.tbl_keys(servers or {})

    require('mason').setup()
    require('mason-lspconfig').setup {}
    require('mason-tool-installer').setup { ensure_installed = keys }

    vim.lsp.enable 'typescript-language-server'
    for _, f in pairs(keys) do
      vim.lsp.config(f, servers[f])
      vim.lsp.enable(f)
    end
  end,
}

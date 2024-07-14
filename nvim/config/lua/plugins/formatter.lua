return { -- autoformat
  'stevearc/conform.nvim',
  dependencies = {
    'tpope/vim-sleuth', -- detect tabstop and shiftwidth
  },
  opts = {
    notify_on_error = true,
    async = true,
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = false,
    },
    formatters_by_ft = {
      astro = { 'prettierd' },
      css = { 'prettier' },
      go = { 'goimports', 'gofmt' },
      graphql = { 'prettierd' },
      html = { 'jq', 'prettierd' },
      json = { 'jq', 'prettierd' },
      jsonc = { 'jq', 'prettierd' },
      javascript = { { 'prettierd' } },
      jsx = { { 'prettierd' } },
      lua = { 'stylua' },
      md = { { 'prettierd' } },
      mdx = { { 'prettierd' } },
      typescript = { { 'prettierd' } },
      typescriptreact = { { 'prettierd' } },
      yaml = { 'prettierd' },
      yml = { 'prettierd' },
    },
    formatters = {
      prettierd = {
        stdin = true,
        env = {
          PRETTIERD_DEFAULT_CONFIG = '/home/joel/.prettierrc',
        },
      },
    },
  },
}

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
      astro = { 'biome', 'prettierd' },
      cpp = { 'clang-format' },
      css = { 'biome', 'prettierd' },
      go = { 'gofmt' },
      graphql = { 'biome', 'prettierd' },
      html = { 'biome', 'prettierd' },
      json = { 'biome', 'prettierd' },
      jsonc = { 'biome', 'prettierd' },
      javascript = { 'biome', 'prettierd' },
      sql = { 'sql_formatter' },
      jsx = { 'biome', 'prettierd' },
      lua = { 'stylua' },
      md = { 'biome', 'prettierd' },
      mdx = { 'biome', 'prettierd' },
      nix = { 'nixfmt' },
      tsx = { 'biome', 'prettierd' },
      typescript = { 'biome', 'prettierd' },
      typescriptreact = { 'biome', 'prettierd' },
      rust = { 'rustfmt', lsp_format = 'fallback' },
      yaml = { 'biome', 'prettierd' },
      yml = { 'biome', 'prettierd' },
    },
    formatters = {
      prettierd = {
        stdin = true,
        env = {
          PRETTIERD_DEFAULT_CONFIG = '/home/joel/dotfiles/prettier/.prettierrc',
        },
      },
      nixfmt = {
        stdin = true,
      },
    },
  },
}

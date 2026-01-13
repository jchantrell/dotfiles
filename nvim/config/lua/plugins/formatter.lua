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
      astro = { 'biome', 'prettierd', stop_after_first = true },
      cpp = { 'clang-format' },
      c = { 'clang-format' },
      css = { 'biome', 'prettierd', stop_after_first = true },
      go = { 'gofmt' },
      graphql = { 'biome', 'prettierd', stop_after_first = true },
      html = { 'biome', 'prettierd', stop_after_first = true },
      json = { 'biome', 'prettierd', stop_after_first = true },
      jsonc = { 'biome', 'prettierd', stop_after_first = true },
      javascript = { 'biome', 'prettierd', stop_after_first = true },
      sql = { 'sql_formatter' },
      jsx = { 'biome', 'prettierd', stop_after_first = true },
      lua = { 'stylua' },
      md = { 'biome', 'prettierd', stop_after_first = true },
      mdx = { 'biome', 'prettierd', stop_after_first = true },
      nix = { 'nixfmt' },
      tsx = { 'biome', 'prettierd', stop_after_first = true },
      typescript = { 'biome', 'prettierd', stop_after_first = true },
      typescriptreact = { 'biome', 'prettierd', stop_after_first = true },
      rust = { 'rustfmt', lsp_format = 'fallback' },
      yaml = { 'biome', 'prettierd', stop_after_first = true },
      yml = { 'biome', 'prettierd', stop_after_first = true },
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

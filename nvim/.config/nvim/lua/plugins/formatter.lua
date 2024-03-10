return { -- autoformat
  'stevearc/conform.nvim',
  dependencies = {
    'tpope/vim-sleuth', -- detect tabstop and shiftwidth
  },
  opts = {
    notify_on_error = false,
    async = true,
    lsp_fallback = true,
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      go = { 'goimports', 'gofmt' },
      javascript = { { 'prettierd', 'prettier' } },
      astro = { 'prettierd', 'prettier' },
      css = { 'prettier' },
    },
    formatters = {
      prettier = {
        args = function(self, ctx)
          -- tailwind + astro arent natively supported by prettier
          if vim.endswith(ctx.filename, '.astro') then
            return {
              '--stdin-filepath',
              '$FILENAME',
              '--plugin',
              'prettier-plugin-astro',
              '--plugin',
              'prettier-plugin-tailwindcss',
            }
          end
          return { '--stdin-filepath', '$FILENAME', '--plugin', 'prettier-plugin-tailwindcss' }
        end,
      },
    },
  },
}

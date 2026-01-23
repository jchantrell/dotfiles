return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  tag = 'v0.10.0',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = { 'bash', 'c', 'html', 'lua', 'markdown', 'vim', 'vimdoc', 'tsx', 'typescript', 'javascript', 'go', 'astro' },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    }
  end,
}

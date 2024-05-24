return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('neo-tree').setup {
      close_if_last_window = true,
      enable_diagnostics = false,
      enable_git_status = false,
      default_component_configs = {},
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_hidden = false,
        },
        hijack_netrw_behavior = 'open_current',
      },
    }

    vim.keymap.set('n', '<leader>st', '')
  end,
}

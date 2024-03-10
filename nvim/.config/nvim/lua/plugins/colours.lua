return { -- colour scheme
  'ramojus/mellifluous.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('mellifluous').setup {
      dim_inactive = false,
    }
    vim.cmd.colorscheme 'mellifluous'
    vim.cmd.hi 'Comment gui=none'
  end,
}

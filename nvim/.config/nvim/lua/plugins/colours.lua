return { -- colour scheme
  'ramojus/mellifluous.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('mellifluous').setup {}
    vim.cmd.colorscheme 'mellifluous'
    vim.cmd.hi 'Comment gui=none'
  end,
}

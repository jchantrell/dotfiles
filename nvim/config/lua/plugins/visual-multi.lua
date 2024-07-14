return {
  'mg979/vim-visual-multi',
  branch = 'master',
  init = function()
    vim.g.VM_maps = {
      ['Find Under'] = '<C-d>',
      ['Select All'] = '<C-a>',
      ['Add Cursor Up'] = '<C-f>',
      ['Add Cursor Down'] = '<C-s>',
      ['Add Cursor At Pos'] = '<C-o>',
    }
    vim.g.VM_default_mappings = 0
  end,
}

return {
  'numToStr/Comment.nvim', -- utils for adding removing line/block comments
  opts = {},
  dependencies = {
    'folke/todo-comments.nvim', -- highlight todo, notes, etc in comments
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
}

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main', -- rewritten branch, required for nvim 0.12+
    lazy = false, -- does not support lazy-loading
    build = ':TSUpdate',
    main = 'nvim-treesitter', -- new module name (NOT nvim-treesitter.configs)
    init = function()
      -- Parser installation (replaces ensure_installed)
      local wanted = { 'bash', 'c', 'html', 'lua', 'markdown', 'vim', 'vimdoc', 'tsx', 'typescript', 'javascript', 'go', 'astro', 'odin', 'rust', 'css', 'python' }
      local installed = require('nvim-treesitter.config').get_installed()
      local to_install = vim
        .iter(wanted)
        :filter(function(p)
          return not vim.tbl_contains(installed, p)
        end)
        :totable()
      if #to_install > 0 then
        require('nvim-treesitter').install(to_install)
      end

      -- Enable highlighting + indentation via FileType autocmd
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start) -- highlighting (built into nvim core)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
}

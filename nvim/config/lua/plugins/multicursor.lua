return {
  'jake-stewart/multicursor.nvim',
  branch = '1.0',
  config = function()
    local mc = require 'multicursor-nvim'
    mc.setup()

    local set = vim.keymap.set

    set({ 'n', 'x' }, '<C-f>', function()
      mc.lineAddCursor(-1)
    end)
    set({ 'n', 'x' }, '<C-s>', function()
      mc.lineAddCursor(1)
    end)
    set({ 'n', 'x' }, '<leader><C-f>', function()
      mc.lineSkipCursor(-1)
    end)
    set({ 'n', 'x' }, '<leader><C-s>', function()
      mc.lineSkipCursor(1)
    end)

    set({ 'n', 'x' }, '<C-d>', function()
      mc.matchAddCursor(1)
    end)
    set({ 'n', 'x' }, '<C-b>', function()
      mc.matchSkipCursor(1)
    end)
    set({ 'n', 'x' }, '<leader><C-D>', function()
      mc.matchAddCursor(-1)
    end)
    set({ 'n', 'x' }, '<leader><C-B>', function()
      mc.matchSkipCursor(-1)
    end)

    set({ 'n', 'x' }, '<C-a>', mc.matchAllAddCursors)

    set({ 'n', 'x' }, '<c-q>', mc.toggleCursor)

    mc.addKeymapLayer(function(layerSet)
      layerSet({ 'n', 'x' }, '<left>', mc.prevCursor)
      layerSet({ 'n', 'x' }, '<right>', mc.nextCursor)

      layerSet({ 'n', 'x' }, '<leader>x', mc.deleteCursor)

      layerSet('n', '<esc>', function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end)
    end)

    local hl = vim.api.nvim_set_hl
    hl(0, 'MultiCursorCursor', { reverse = true })
    hl(0, 'MultiCursorVisual', { link = 'Visual' })
    hl(0, 'MultiCursorSign', { link = 'SignColumn' })
    hl(0, 'MultiCursorMatchPreview', { link = 'Search' })
    hl(0, 'MultiCursorDisabledCursor', { reverse = true })
    hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
    hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
  end,
}

local wezterm = require 'wezterm'
local wsl_domains = wezterm.default_wsl_domains()
local target_triple = wezterm.target_triple
local launch_menu = {}

wezterm.on('SpawnCommandInNewWindowInCurrentWorkingDirectory', function(window, pane)
  window:perform_action(
    wezterm.action { SpawnCommandInNewWindow = {
      domain = 'CurrentPaneDomain',
    } },
    pane
  )
end)

wezterm.on('SpawnCommandInNewTabInCurrentWorkingDirectory', function(window, pane)
  window:perform_action(
    wezterm.action { SpawnCommandInNewTab = {
      domain = 'CurrentPaneDomain',
    } },
    pane
  )
end)

wezterm.on('SplitVerticalInCurrentWorkingDirectory', function(window, pane)
  window:perform_action(
    wezterm.action { SplitVertical = {
      domain = 'CurrentPaneDomain',
    } },
    pane
  )
end)

wezterm.on('SplitHorizontalCurrentWorkingDirectory', function(window, pane)
  window:perform_action(
    wezterm.action { SplitHorizontal = {
      domain = 'CurrentPaneDomain',
    } },
    pane
  )
end)

local keys = {
  { action = wezterm.action.CopyTo 'Clipboard', mods = 'CTRL|SHIFT', key = 'C' },
  { action = wezterm.action.DecreaseFontSize, mods = 'CTRL', key = '-' },
  { action = wezterm.action.IncreaseFontSize, mods = 'CTRL', key = '=' },
  { action = wezterm.action.Nop, mods = 'ALT', key = 'Enter' },
  { action = wezterm.action.PasteFrom 'Clipboard', mods = 'CTRL|SHIFT', key = 'V' },
  { action = wezterm.action.ResetFontSize, mods = 'CTRL', key = '0' },
  { action = wezterm.action.ToggleFullScreen, key = 'F11' },
  { action = wezterm.action.ShowDebugOverlay, key = 'L', mods = 'CTRL' },
  { action = wezterm.action.ShowLauncher, key = 'Space', mods = 'ALT|CTRL|SHIFT' },
  { action = wezterm.action.ShowLauncherArgs { flags = 'LAUNCH_MENU_ITEMS' }, key = 'Space', mods = 'CTRL' },
  { action = wezterm.action.CloseCurrentPane { confirm = false }, key = 'x', mods = 'ALT|SHIFT' },
  { action = wezterm.action.CloseCurrentTab { confirm = false }, key = 'x', mods = 'CTRL|SHIFT' },
  {
    action = wezterm.action { EmitEvent = 'SpawnCommandInNewWindowInCurrentWorkingDirectory' },
    key = 'n',
    mods = 'ALT|SHIFT',
  },
  {
    action = wezterm.action { EmitEvent = 'SpawnCommandInNewTabInCurrentWorkingDirectory' },
    key = 't',
    mods = 'ALT|SHIFT',
  },
  {
    action = wezterm.action { EmitEvent = 'SplitVerticalInCurrentWorkingDirectory' },
    key = '_',
    mods = 'ALT|SHIFT',
  },
  {
    action = wezterm.action { EmitEvent = 'SplitHorizontalCurrentWorkingDirectory' },
    key = '+',
    mods = 'ALT|SHIFT',
  },
  { key = 'LeftArrow', mods = 'SHIFT', action = wezterm.action { ActivatePaneDirection = 'Left' } },
  { key = 'DownArrow', mods = 'SHIFT', action = wezterm.action { ActivatePaneDirection = 'Down' } },
  { key = 'UpArrow', mods = 'SHIFT', action = wezterm.action { ActivatePaneDirection = 'Up' } },
  { key = 'RightArrow', mods = 'SHIFT', action = wezterm.action { ActivatePaneDirection = 'Right' } },
  { key = 'LeftArrow', mods = 'ALT|SHIFT', action = wezterm.action { AdjustPaneSize = { 'Left', 5 } } },
  { key = 'DownArrow', mods = 'ALT|SHIFT', action = wezterm.action { AdjustPaneSize = { 'Down', 5 } } },
  { key = 'UpArrow', mods = 'ALT|SHIFT', action = wezterm.action { AdjustPaneSize = { 'Up', 5 } } },
  { key = 'RightArrow', mods = 'ALT|SHIFT', action = wezterm.action { AdjustPaneSize = { 'Right', 5 } } },
}

local config = {
  front_end = 'OpenGL',
  max_fps = 120,
  animation_fps = 1,
  default_cursor_style = 'BlinkingBlock',
  cursor_blink_rate = 500,
  adjust_window_size_when_changing_font_size = false,
  audible_bell = 'Disabled',
  canonicalize_pasted_newlines = 'None',
  color_scheme = 'muted',
  colors = {
    background = 'hsl: 2 3 12',
  },
  inactive_pane_hsb = {
    saturation = 1,
    brightness = 1,
  },
  disable_default_key_bindings = true,
  exit_behavior = 'Close',
  font_size = 14,
  font = wezterm.font 'Codelia',
  force_reverse_video_cursor = true,
  keys = keys,
  scrollback_lines = 10000,
  use_dead_keys = false,
  unicode_version = 14,
  window_decorations = 'RESIZE',
  window_close_confirmation = 'NeverPrompt',
  window_padding = {
    left = 0,
    right = 0,
    top = 1,
    bottom = 0,
  },
  ssh_domains = {
    {
      name = 'woodside',
      remote_address = '192.168.20.4',
      username = 'juniper',
      multiplexing = 'None',
      assume_shell = 'Posix',
    },
  },
}

if target_triple == 'x86_64-pc-windows-msvc' then
  for _, dom in ipairs(wsl_domains) do
    if dom.distribution == 'Ubuntu-24.04' then
      table.insert(launch_menu, {
        label = 'Linux',
        domain = { DomainName = dom.name },
      })
    end
  end
  table.insert(launch_menu, {
    label = 'PowerShell',
    domain = { DomainName = 'local' },
    args = { 'pwsh.exe', '-NoLogo' },
  })
  table.insert(launch_menu, {
    label = 'CMD',
    domain = { DomainName = 'local' },
    args = { 'cmd.exe', '-NoLogo' },
  })
  table.insert(launch_menu, {
    label = 'Mac',
    domain = { DomainName = 'local' },
    args = { 'wezterm', 'cli', 'spawn', '--domain-name', 'woodside' },
  })

  config.wsl_domains = wsl_domains
end

if target_triple == 'x86_64-unknown-linux-gnu' then
  table.insert(launch_menu, {
    label = 'Home',
    domain = { DomainName = 'local' },
    args = { 'cd' },
  })
end

config.launch_menu = launch_menu

for i = 1, 8 do
  table.insert(config.keys, {
    key = 'F' .. tostring(i),
    action = wezterm.action.ActivateTab(i - 1),
  })
end

return config

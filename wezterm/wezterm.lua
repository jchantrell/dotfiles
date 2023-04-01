local wezterm = require 'wezterm'
local wsl_domains = wezterm.default_wsl_domains()
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"
local launch_menu = {}

table.insert(launch_menu, {
    label = 'WSL',
    args={ "wsl.exe", "--cd", '~'},
})
table.insert(launch_menu, {
    label = 'PowerShell',
    args = { 'powershell.exe', '-NoLogo' },
})
table.insert(launch_menu, {
    label = 'CMD',
    args = { 'cmd.exe', '-NoLogo' },
})

wezterm.on("SpawnCommandInNewWindowInCurrentWorkingDirectory", function(window, pane)
	current_directory = pane:get_current_working_dir():gsub('file://joel%-desktop', '')
	window:perform_action(wezterm.action{SpawnCommandInNewWindow={
		args={ "wsl.exe", "--cd", current_directory }
  }}, pane)
end)

wezterm.on("SpawnCommandInNewTabInCurrentWorkingDirectory", function(window, pane)
	current_directory = pane:get_current_working_dir():gsub('file://joel%-desktop', '')
  	window:perform_action(wezterm.action{SpawnCommandInNewTab={
    args={ "wsl.exe", "--cd", current_directory }
  }}, pane)
end)

wezterm.on("SplitVerticalInCurrentWorkingDirectory", function(window, pane)
	current_directory = pane:get_current_working_dir():gsub('file://joel%-desktop', '')
	print('wtf')
	window:perform_action(wezterm.action{SplitVertical={
    args={ "wsl.exe", "--cd", current_directory}
  }}, pane)
end)

wezterm.on("SplitHorizontalCurrentWorkingDirectory", function(window, pane)
	current_directory = pane:get_current_working_dir():gsub('file://joel%-desktop', '')
	window:perform_action(wezterm.action{SplitHorizontal={
    args={ "wsl.exe", "--cd", current_directory }
  }}, pane)	
end)

for _, dom in ipairs(wsl_domains) do
    dom.default_cwd = "~"
end

local config = {
  adjust_window_size_when_changing_font_size = false,
  audible_bell = 'Disabled',
  -- colors = {
  --   foreground = '#C0C5CE',
  --   background = '#2B303B',

  --   ansi = {
  --     '#4C4C4C', -- black
  --     '#FF3C3C', -- red
  --     '#0DBC79', -- green
  --     '#E5E510', -- yellow
  --     '#3B8EEA', -- blue
  --     '#BC3FBC', -- magenta
  --     '#11A8CD', -- cyan
  --     '#E5E5E5', -- white
  --   },

  --   brights = {
  --     '#666666', -- black
  --     '#F14C4C', -- red
  --     '#23D18B', -- green
  --     '#F5F543', -- yellow
  --     '#3B8EEA', -- blue
  --     '#D670D6', -- magenta
  --     '#29B8DB', -- cyan
  --     '#E5E5E5', -- white
  --   }
  -- },
  color_scheme = 'Material (Gogh)',
  disable_default_key_bindings = true,
  exit_behavior = 'Close',
  font_size = 17.1,
  force_reverse_video_cursor = true,
  hide_tab_bar_if_only_one_tab = true,

  keys = {
    { action = wezterm.action.CopyTo 'Clipboard', mods = 'CTRL|SHIFT', key = 'C' },
    { action = wezterm.action.DecreaseFontSize, mods = 'CTRL', key = '-' },
    { action = wezterm.action.IncreaseFontSize, mods = 'CTRL', key = '=' },
    { action = wezterm.action.Nop, mods = 'ALT', key = 'Enter' },
    { action = wezterm.action.PasteFrom 'Clipboard', mods = 'CTRL|SHIFT', key = 'V' },
    { action = wezterm.action.ResetFontSize, mods = 'CTRL', key = '0' },
    { action = wezterm.action.ToggleFullScreen, key = 'F11' },
    { action = wezterm.action.ShowDebugOverlay, key = 'L', mods = 'CTRL' },
    { action = wezterm.action.ShowLauncherArgs {flags = 'LAUNCH_MENU_ITEMS'}, key = 'Space', mods = 'CTRL' },

    -- Tabs and Panes
    { action = wezterm.action.CloseCurrentPane { confirm = false }, key = "x", mods = "ALT|SHIFT"},
    { action = wezterm.action.CloseCurrentTab { confirm = false }, key = "x", mods = "CTRL|SHIFT"},
    { action = wezterm.action{EmitEvent="SpawnCommandInNewWindowInCurrentWorkingDirectory"}, key = "n", mods = "CTRL|SHIFT" },
    { action = wezterm.action{EmitEvent="SpawnCommandInNewTabInCurrentWorkingDirectory"}, key = "t", mods = "CTRL|SHIFT" },
    { action = wezterm.action{EmitEvent="SplitVerticalInCurrentWorkingDirectory"}, key = "_", mods = "ALT|SHIFT", },
    { action = wezterm.action{EmitEvent="SplitHorizontalCurrentWorkingDirectory"}, key = "+", mods = "ALT|SHIFT", },
    { key = "h", mods = "ALT", action = wezterm.action{ActivatePaneDirection="Left"}},
    { key = "j", mods = "ALT", action = wezterm.action{ActivatePaneDirection="Down"}},
    { key = "k", mods = "ALT", action = wezterm.action{ActivatePaneDirection="Up"}},
    { key = "l", mods = "ALT", action = wezterm.action{ActivatePaneDirection="Right"}},
    { key = "H", mods = "ALT|SHIFT", action = wezterm.action{AdjustPaneSize={"Left", 5}}},
    { key = "J", mods = "ALT|SHIFT", action = wezterm.action{AdjustPaneSize={"Down", 5}}},
    { key = "K", mods = "ALT|SHIFT", action = wezterm.action{AdjustPaneSize={"Up", 5}}},
    { key = "L", mods = "ALT|SHIFT", action = wezterm.action{AdjustPaneSize={"Right", 5}}},

  },
  scrollback_lines = 10000,
  show_update_window = true,
  use_dead_keys = false,
  unicode_version = 14,
  window_close_confirmation = 'NeverPrompt',
  window_background_opacity = 0.97,
  window_padding = {
    left = 0,
    right = 0,
    top = '0.2cell',
    bottom = 0,
  },
  wsl_domains =  wsl_domains,
  launch_menu = launch_menu,
}

-- Activate tab keys
for i = 1, 8 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CTRL|ALT',
    action = wezterm.action.ActivateTab(i - 1),
  })
  table.insert(config.keys, {
    key = 'F' .. tostring(i),
    action = wezterm.action.ActivateTab(i - 1),
  })
end

return config
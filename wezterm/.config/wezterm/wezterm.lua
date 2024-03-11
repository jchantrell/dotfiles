local wezterm = require("wezterm")
local launch_menu = {}

wezterm.on("SpawnCommandInNewWindowInCurrentWorkingDirectory", function(window, pane)
	window:perform_action(
		wezterm.action({ SpawnCommandInNewWindow = {
			domain = "CurrentPaneDomain",
		} }),
		pane
	)
end)

wezterm.on("SpawnCommandInNewTabInCurrentWorkingDirectory", function(window, pane)
	window:perform_action(
		wezterm.action({ SpawnCommandInNewTab = {
			domain = "CurrentPaneDomain",
		} }),
		pane
	)
end)

wezterm.on("SplitVerticalInCurrentWorkingDirectory", function(window, pane)
	window:perform_action(
		wezterm.action({ SplitVertical = {
			domain = "CurrentPaneDomain",
		} }),
		pane
	)
end)

wezterm.on("SplitHorizontalCurrentWorkingDirectory", function(window, pane)
	window:perform_action(
		wezterm.action({ SplitHorizontal = {
			domain = "CurrentPaneDomain",
		} }),
		pane
	)
end)

local keys = {
	{ action = wezterm.action.CopyTo("Clipboard"), mods = "CTRL|SHIFT", key = "C" },
	{ action = wezterm.action.DecreaseFontSize, mods = "CTRL", key = "-" },
	{ action = wezterm.action.IncreaseFontSize, mods = "CTRL", key = "=" },
	{ action = wezterm.action.Nop, mods = "ALT", key = "Enter" },
	{ action = wezterm.action.PasteFrom("Clipboard"), mods = "CTRL|SHIFT", key = "V" },
	{ action = wezterm.action.ResetFontSize, mods = "CTRL", key = "0" },
	{ action = wezterm.action.ToggleFullScreen, key = "F11" },
	{ action = wezterm.action.ShowDebugOverlay, key = "L", mods = "CTRL" },
	{ action = wezterm.action.ShowLauncher, key = "Space", mods = "CTRL" },
	{ action = wezterm.action.CloseCurrentPane({ confirm = false }), key = "x", mods = "ALT|SHIFT" },
	{ action = wezterm.action.CloseCurrentTab({ confirm = false }), key = "x", mods = "CTRL|SHIFT" },
	{
		action = wezterm.action({ EmitEvent = "SpawnCommandInNewWindowInCurrentWorkingDirectory" }),
		key = "n",
		mods = "CTRL|SHIFT",
	},
	{
		action = wezterm.action({ EmitEvent = "SpawnCommandInNewTabInCurrentWorkingDirectory" }),
		key = "t",
		mods = "CTRL|SHIFT",
	},
	{
		action = wezterm.action({ EmitEvent = "SplitVerticalInCurrentWorkingDirectory" }),
		key = "_",
		mods = "ALT|SHIFT",
	},
	{
		action = wezterm.action({ EmitEvent = "SplitHorizontalCurrentWorkingDirectory" }),
		key = "+",
		mods = "ALT|SHIFT",
	},
	{ key = "h", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
	{ key = "j", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
	{ key = "k", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
	{ key = "l", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
	{ key = "H", mods = "ALT|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }) },
	{ key = "J", mods = "ALT|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }) },
	{ key = "K", mods = "ALT|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }) },
	{ key = "L", mods = "ALT|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }) },
}

-- c library for random needs to be seeded
math.randomseed(os.time())
for i = 1, 3 do
	math.random(10000, 65000)
end

local randomBackground = function()
	local fileNames = {}
	for dir in io.popen([[ls -pa ~/pics/background | grep -v /]]):lines() do
		table.insert(fileNames, dir)
	end
	local num = math.floor(math.random() * #fileNames) + 1
	return string.gsub("pics/background/$file", "%$(%w+)", fileNames[num])
end

local config = {
	adjust_window_size_when_changing_font_size = false,
	audible_bell = "Disabled",
	color_scheme = "Highway (Gogh)",
	disable_default_key_bindings = true,
	exit_behavior = "Close",
	font_size = 16,
	force_reverse_video_cursor = true,
	hide_tab_bar_if_only_one_tab = true,
	keys = keys,
	background = {
		{
			source = {
				File = randomBackground(),
			},
			hsb = { brightness = 0.1 },
		},
	},
	scrollback_lines = 10000,
	show_update_window = false,
	use_dead_keys = false,
	unicode_version = 14,
	window_close_confirmation = "NeverPrompt",
	window_padding = {
		left = 0,
		right = 0,
		top = 1,
		bottom = 0,
	},
	launch_menu = launch_menu,
	canonicalize_pasted_newlines = "None",
}

for i = 1, 8 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivateTab(i - 1),
	})
	table.insert(config.keys, {
		key = "F" .. tostring(i),
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config

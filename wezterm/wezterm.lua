local wezterm = require("wezterm")
local wsl_domains = wezterm.default_wsl_domains()
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

for idx, dom in ipairs(wsl_domains) do
	docker = string.find(dom.name, "docker")
	if docker == nil then
		table.insert(launch_menu, {
			label = dom.distribution,
			domain = { DomainName = dom.name },
		})
	end
end

table.insert(launch_menu, {
	label = "PowerShell",
	domain = { DomainName = "local" },
	args = { "pwsh.exe", "-NoLogo" },
})

table.insert(launch_menu, {
	label = "CMD",
	domain = { DomainName = "local" },
	args = { "cmd.exe", "-NoLogo" },
})

local keys = {
	{ action = wezterm.action.CopyTo("Clipboard"), mods = "CTRL|SHIFT", key = "C" },
	{ action = wezterm.action.DecreaseFontSize, mods = "CTRL", key = "-" },
	{ action = wezterm.action.IncreaseFontSize, mods = "CTRL", key = "=" },
	{ action = wezterm.action.Nop, mods = "ALT", key = "Enter" },
	{ action = wezterm.action.PasteFrom("Clipboard"), mods = "CTRL|SHIFT", key = "V" },
	{ action = wezterm.action.ResetFontSize, mods = "CTRL", key = "0" },
	{ action = wezterm.action.ToggleFullScreen, key = "F11" },
	{ action = wezterm.action.ShowDebugOverlay, key = "L", mods = "CTRL" },
	{ action = wezterm.action.ShowLauncher, key = "Space", mods = "ALT|CTRL|SHIFT" },
	{ action = wezterm.action.ShowLauncherArgs({ flags = "LAUNCH_MENU_ITEMS" }), key = "Space", mods = "CTRL" },
	{ action = wezterm.action.CloseCurrentPane({ confirm = false }), key = "x", mods = "ALT|SHIFT" },
	{ action = wezterm.action.CloseCurrentTab({ confirm = false }), key = "x", mods = "CTRL|SHIFT" },
	{
		action = wezterm.action({ EmitEvent = "SpawnCommandInNewWindowInCurrentWorkingDirectory" }),
		key = "n",
		mods = "ALT|SHIFT",
	},
	{
		action = wezterm.action({ EmitEvent = "SpawnCommandInNewTabInCurrentWorkingDirectory" }),
		key = "t",
		mods = "ALT|SHIFT",
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
	window_background_opacity = 0.9,
	scrollback_lines = 10000,
	show_update_window = false,
	use_dead_keys = false,
	unicode_version = 14,
	window_decorations = "RESIZE",
	window_close_confirmation = "NeverPrompt",
	window_padding = {
		left = 0,
		right = 0,
		top = 1,
		bottom = 0,
	},
	launch_menu = launch_menu,
	wsl_domains = wsl_domains,
	canonicalize_pasted_newlines = "None",
	default_prog = { "pwsh.exe", "-NoLogo" },
}

for i = 1, 8 do
	table.insert(config.keys, {
		key = "F" .. tostring(i),
		action = wezterm.action.ActivateTab(i - 1),
	})
end

return config

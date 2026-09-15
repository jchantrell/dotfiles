local wezterm = require("wezterm")
local wsl_domains = wezterm.default_wsl_domains()
local target_triple = wezterm.target_triple
local launch_menu = {}

wezterm.on("SpawnCommandInNewWindowInCurrentWorkingDirectory", function(window, pane)
	window:perform_action(
		wezterm.action({
			SpawnCommandInNewWindow = {
				domain = "CurrentPaneDomain",
			},
		}),
		pane
	)
end)

wezterm.on("SpawnCommandInNewTabInCurrentWorkingDirectory", function(window, pane)
	window:perform_action(
		wezterm.action({
			SpawnCommandInNewTab = {
				domain = "CurrentPaneDomain",
			},
		}),
		pane
	)
end)

wezterm.on("SplitVerticalInCurrentWorkingDirectory", function(window, pane)
	window:perform_action(
		wezterm.action({
			SplitVertical = {
				domain = "CurrentPaneDomain",
			},
		}),
		pane
	)
end)

wezterm.on("SplitHorizontalCurrentWorkingDirectory", function(window, pane)
	window:perform_action(
		wezterm.action({
			SplitHorizontal = {
				domain = "CurrentPaneDomain",
			},
		}),
		pane
	)
end)

local function hash_to_colors(str, is_active)
	if not str or str == "" then
		return nil, nil
	end
	local hash = 5381
	for i = 1, #str do
		hash = ((hash * 33) + string.byte(str, i)) % 0xFFFFFFFF
	end
	local hue = hash % 360
	local saturation = 60 + (hash % 20)
	local text_lightness = 65 + (hash % 15)
	local bg_lightness = is_active and 25 or 15
	local foreground = string.format("hsl:%d %d %d", hue, saturation, text_lightness)
	local background = string.format("hsl:%d %d %d", hue, saturation, bg_lightness)
	return foreground, background
end

wezterm.on("format-tab-title", function(tab)
	local domain_name = tab.active_pane.domain_name
	local foreground, background = hash_to_colors(domain_name, tab.is_active)
	local pane_title = tab.active_pane.title
	if domain_name and domain_name ~= "local" and domain_name ~= "" then
		local cwd = tab.active_pane.current_working_dir
		if cwd then
			local path = cwd.file_path or ""
			path = path:gsub("^/root", "~"):gsub("^/home/[^/]+", "~")
			pane_title = path
		else
			pane_title = domain_name
		end
	end
	local title = string.format("%d) %s", tab.tab_index + 1, pane_title)
	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
	}
end)

local keys = {
	{
		action = wezterm.action.CopyTo("Clipboard"),
		mods = "CTRL|SHIFT",
		key = "C",
	},
	{
		action = wezterm.action.DecreaseFontSize,
		mods = "CTRL",
		key = "-",
	},
	{
		action = wezterm.action.IncreaseFontSize,
		mods = "CTRL",
		key = "=",
	},
	{
		action = wezterm.action.Nop,
		mods = "ALT",
		key = "Enter",
	},
	{
		action = wezterm.action.PasteFrom("Clipboard"),
		mods = "CTRL|SHIFT",
		key = "V",
	},
	{
		action = wezterm.action.ResetFontSize,
		mods = "CTRL",
		key = "0",
	},
	{ action = wezterm.action.ToggleFullScreen, key = "F11" },
	{
		action = wezterm.action.ShowDebugOverlay,
		key = "L",
		mods = "CTRL",
	},
	{
		action = wezterm.action.ShowLauncher,
		key = "Space",
		mods = "ALT|CTRL|SHIFT",
	},
	{
		action = wezterm.action.ShowLauncherArgs({ flags = "LAUNCH_MENU_ITEMS|DOMAINS" }),
		key = "Space",
		mods = "CTRL",
	},
	{
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
		key = "x",
		mods = "ALT|SHIFT",
	},
	{
		action = wezterm.action.CloseCurrentTab({ confirm = false }),
		key = "x",
		mods = "CTRL|SHIFT",
	},
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
	{ key = "LeftArrow", mods = "SHIFT", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
	{ key = "DownArrow", mods = "SHIFT", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
	{ key = "UpArrow", mods = "SHIFT", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
	{ key = "RightArrow", mods = "SHIFT", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
	{ key = "LeftArrow", mods = "ALT|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Left", 5 } }) },
	{ key = "DownArrow", mods = "ALT|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Down", 5 } }) },
	{ key = "UpArrow", mods = "ALT|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Up", 5 } }) },
	{ key = "RightArrow", mods = "ALT|SHIFT", action = wezterm.action({ AdjustPaneSize = { "Right", 5 } }) },
}

local config = {
	max_fps = 120,
	animation_fps = 1,
	default_cursor_style = "BlinkingBlock",
	cursor_blink_rate = 500,
	adjust_window_size_when_changing_font_size = false,
	audible_bell = "Disabled",
	canonicalize_pasted_newlines = "None",
	colors = {
		foreground = "#f0f0f0",
		background = "#1a1a1a",
		cursor_bg = "#f0f0f0",
		cursor_fg = "#f0f0f0",
		cursor_border = "#262626",
		split = "#4c4c4c",
		ansi = { "#8f8aac", "#ac8a8c", "#bf9ac1", "#aca98a", "#8aabac", "#ac8aac", "#8aabac", "#e7e7e8" },
		brights = { "#a39ec4", "#c49ea0", "#d7a7d2", "#c4c19e", "#9ec3c4", "#c49ec4", "#bfaf8e", "#f0f0f0" },
		tab_bar = {
			background = "#1a1a1a",
			new_tab = { bg_color = "#1a1a1a", fg_color = "#808080" },
			new_tab_hover = { bg_color = "#333333", fg_color = "#f0f0f0" },
		},
	},
	inactive_pane_hsb = {
		saturation = 1,
		brightness = 1,
	},
	disable_default_key_bindings = true,
	exit_behavior = "Close",
	font_size = 12,
	font = wezterm.font("Codelia"),
	force_reverse_video_cursor = true,
	keys = keys,
	native_macos_fullscreen = true,
	scrollback_lines = 10000,
	use_dead_keys = false,
	unicode_version = 14,
	window_close_confirmation = "NeverPrompt",
	window_frame = {
		font = require("wezterm").font("Codelia"),
		font_size = 11,
		inactive_titlebar_bg = "#1a1a1a",
		active_titlebar_bg = "#1a1a1a",
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 1,
		bottom = 0,
	},
	ssh_domains = {
		{
			name = "atlas",
			remote_address = "atlas",
			username = "root",
			multiplexing = "None",
			assume_shell = "Posix",
		},
		{
			name = "hera",
			remote_address = "192.168.20.5",
			username = "joel",
			multiplexing = "None",
			assume_shell = "Posix",
		},
	},
}

if target_triple == "x86_64-pc-windows-msvc" then
	for _, dom in ipairs(wsl_domains) do
		if dom.distribution == "Ubuntu-24.04" then
			table.insert(launch_menu, {
				label = "Linux",
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

	config.wsl_domains = wsl_domains
end

for i = 1, 8 do
	table.insert(config.keys, {
		key = "F" .. tostring(i),
		action = wezterm.action.ActivateTab(i - 1),
	})
end

config.launch_menu = launch_menu
config.window_decorations = "NONE"

return config

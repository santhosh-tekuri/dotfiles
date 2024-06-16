local wezterm = require 'wezterm'
local act = wezterm.action
local font = wezterm.font 'Cascadia Code ExtraLight'

return {
    term = "wezterm",
    window_frame = {
        font = font,
        font_size = 15,
    },
    window_padding = {
        left = 10,
        right = 0,
        top = 0,
        bottom = 0,
    },
    scrollback_lines = 99999,
    color_scheme = "Tango (terminal.sexy)",
    colors = {
        foreground = '#dcd7ba',
        background = '#1f1f28',
        cursor_bg = "#dcd7ba",
        cursor_fg = "#1f1f28",
    },
    font = font,
    font_size = 18,
    line_height = 1.2,
    initial_rows = 35,
    initial_cols = 150,
    hide_tab_bar_if_only_one_tab = true,
    use_fancy_tab_bar = false,
    keys = {
        { key = 'Enter',      mods = 'ALT',        action = wezterm.action.DisableDefaultAssignment },
        { key = 'q',          mods = 'CTRL',       action = act { SendString = "\x11" } }, -- detect ctrl-q. see issue 2630
        { key = 'LeftArrow',  mods = 'OPT',        action = act.SendKey { key = 'b', mods = 'ALT' } },
        { key = 'RightArrow', mods = 'OPT',        action = act.SendKey { key = 'f', mods = 'ALT' } },
        { key = 'LeftArrow',  mods = 'SUPER',      action = act.SendKey { key = 'a', mods = 'CTRL' } },
        { key = 'RightArrow', mods = 'SUPER',      action = act.SendKey { key = 'e', mods = 'CTRL' } },
        { key = 'k',          mods = 'SUPER',      action = act.ClearScrollback 'ScrollbackAndViewport' },
        { key = 'K',          mods = 'CTRL|SHIFT', action = act.ClearScrollback 'ScrollbackAndViewport' },
    },
}

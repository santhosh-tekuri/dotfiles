local wezterm = require 'wezterm'
local act = wezterm.action

return {
    window_padding = {
        left = 10,
        right = 0,
        top = 0,
        bottom = 0,
    },
    color_scheme = "Tango (terminal.sexy)",
    colors = {
        foreground = '#FFFFFF',
        background = '#252525',
    },
    font = wezterm.font 'Cascadia Code Light',
    font_size = 18,
    line_height = 1.2,
    initial_rows = 35,
    initial_cols = 150,
    hide_tab_bar_if_only_one_tab = true,
    keys = {
        { key='LeftArrow', mods='OPT', action=act.SendKey{key='b', mods='ALT'}},
        { key='RightArrow', mods='OPT', action=act.SendKey{key='f', mods='ALT'}},
        { key='LeftArrow', mods='SUPER', action=act.SendKey{key='a', mods='CTRL'}},
        { key='RightArrow', mods='SUPER', action=act.SendKey{key='e', mods='CTRL'}},
        { key='k', mods='SUPER', action=act.ClearScrollback 'ScrollbackAndViewport'},
        { key='K', mods='CTRL|SHIFT', action=act.ClearScrollback 'ScrollbackAndViewport'},
    },
}
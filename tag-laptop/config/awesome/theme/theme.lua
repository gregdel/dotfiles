-- Imports
local os = { getenv = os.getenv }
local home = os.getenv("HOME")
local theme_dir = home .. "/.config/awesome/theme"

-- Colors
local fg_normal  = "#D3DAE3"
local fg_focus   = "#F0DFAF"
local fg_urgent  = "#CC9393"
local bg_normal  = "#383C4A"
local bg_focus   = "#22242D"
local bg_urgent  = "#383C4A"
local border_normal = "#3F3F3F"
local border_focus  = "#6F6F6F"
local border_marked = "#CC9393"

local theme = {}
theme.wallpaper = home .. "/pictures/Wallpapers/Yosemite-valley-HD-nature-wallpaper.jpg"

-- Font
theme.font      = "InconsolataForPowerline Nerd Font 12"

-- Colors
theme.fg_normal  = fg_normal
theme.fg_focus   = fg_focus
theme.fg_urgent  = fg_urgent
theme.bg_normal  = bg_normal
theme.bg_focus   = bg_focus
theme.bg_urgent  = bg_urgent
theme.bg_systray = theme.bg_normal

-- Borders
theme.useless_gap   = 0
theme.border_width  = 2
theme.border_normal = border_normal
theme.border_focus  = border_focus
theme.border_marked = border_marked

-- Titlebars
theme.titlebar_bg_focus  = bg_focus
theme.titlebar_bg_normal = bg_normal

-- Tasklist
theme.tasklist_fg_focus  = fg_focus
theme.tasklist_fg_normal = fg_normal
theme.tasklist_bg_focus  = bg_focus
theme.tasklist_bg_normal = bg_normal

-- Taglist
theme.taglist_fg_focus  = fg_focus
theme.taglist_fg_normal = fg_normal
theme.taglist_bg_focus  = bg_focus
theme.taglist_bg_normal = bg_normal

-- Taglist
-- theme.taglist.fg_focus  = "#000000"
-- theme.titlebar_bg_normal = "#3F3F3F"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"

-- Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"

-- Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]

-- Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = 15
theme.menu_width  = 100

-- Taglist icons
theme.taglist_squares_sel   = theme_dir .. "/taglist/squarefz.png"
theme.taglist_squares_unsel = theme_dir .. "/taglist/squarez.png"
theme.taglist_squares_resize = "true"

-- Misc
theme.awesome_icon           = theme_dir .. "/awesome-icon.png"
theme.menu_submenu_icon      = theme_dir .. "submenu.png"

-- Layout
theme.layout_tile       = theme_dir .. "/layouts/tile.png"
theme.layout_tileleft   = theme_dir .. "/layouts/tileleft.png"
theme.layout_tilebottom = theme_dir .. "/layouts/tilebottom.png"
theme.layout_tiletop    = theme_dir .. "/layouts/tiletop.png"
theme.layout_fairv      = theme_dir .. "/layouts/fairv.png"
theme.layout_fairh      = theme_dir .. "/layouts/fairh.png"
theme.layout_spiral     = theme_dir .. "/layouts/spiral.png"
theme.layout_dwindle    = theme_dir .. "/layouts/dwindle.png"
theme.layout_max        = theme_dir .. "/layouts/max.png"
theme.layout_fullscreen = theme_dir .. "/layouts/fullscreen.png"
theme.layout_magnifier  = theme_dir .. "/layouts/magnifier.png"
theme.layout_floating   = theme_dir .. "/layouts/floating.png"
theme.layout_cornernw   = theme_dir .. "/layouts/cornernw.png"
theme.layout_cornerne   = theme_dir .. "/layouts/cornerne.png"
theme.layout_cornersw   = theme_dir .. "/layouts/cornersw.png"
theme.layout_cornerse   = theme_dir .. "/layouts/cornerse.png"

-- Titlebar
theme.titlebar_close_button_focus  = theme_dir .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme_dir .. "/titlebar/close_normal.png"

theme.titlebar_minimize_button_normal = theme_dir .. "/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = theme_dir .. "/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active  = theme_dir .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = theme_dir .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = theme_dir .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme_dir .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = theme_dir .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = theme_dir .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = theme_dir .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme_dir .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = theme_dir .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = theme_dir .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = theme_dir .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme_dir .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = theme_dir .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = theme_dir .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme_dir .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme_dir .. "/titlebar/maximized_normal_inactive.png"

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local awful = require("awful")

local wifiwidget = { mt = {} }

local function update(w)
    local fh = assert(io.popen("/usr/sbin/iwgetid --raw", "r"))
    local network = fh:read("*l")
    fh:close()
    if network == nil then
        w:set_text("No wifi ")
    else
        w:set_text(network .. " ")
    end
end

local function handle_click()
    awful.spawn("urxvt -e nmtui")
end

function wifiwidget.new()
    local w = textbox()
    local timeout = 20

    function w.update()
        update(w)
        return true
    end

    -- Timer
    local t = timer.weak_start_new(timeout, w.update)
    t:emit_signal("timeout")

    -- Mouse
    w:connect_signal("button::press", handle_click)

    return w
end

function wifiwidget.mt:__call()
    return wifiwidget.new()
end

return setmetatable(wifiwidget, wifiwidget.mt)

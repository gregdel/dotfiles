local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")

local volumewidget = { mt = {} }

local function update(w)
    local icon = ''
    local volume = ''
    local volmax = 65536
    local f = io.popen("pamixer --get-volume")
    local g = io.popen("pamixer --get-mute")
    local v = f:read()
    local mute = g:read()
    if mute ~= nil and string.find(mute, "false") then
        volume = tonumber(v) .."% "
        icon = ''
    end
    f:close()
    g:close()
    w:set_text(volume .. icon)
end

--- Create a volume widget
function volumewidget.new()
    local w = textbox()
    local timeout = 20

    function w.update()
        update(w)
        return true -- Continue the timer
    end
    local t = timer.weak_start_new(timeout, w.update)
    t:emit_signal("timeout")
    return w
end

function volumewidget.mt:__call()
    return volumewidget.new()
end

return setmetatable(volumewidget, volumewidget.mt)

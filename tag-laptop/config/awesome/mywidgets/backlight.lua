local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")

local backlightwidget = { mt = {} }

local function update(w)
    local fh = assert(io.popen("/usr/bin/xbacklight -get", "r"))
    local out = fh:read("*l")
    fh:close()
    local value
    if out == nil then
        value = "?"
    else
        value = math.floor(tonumber(out))
    end

    w:set_text(value .. "% ")
end

function backlightwidget.new()
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

function backlightwidget.mt:__call()
    return backlightwidget.new()
end

return setmetatable(backlightwidget, backlightwidget.mt)

local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")

local batterywidget = { mt = {} }

local function update(w)
    local icon
    local fh = assert(io.popen("acpi | cut -d, -f 2,3 -", "r"))
    local output = fh:read("*l")
    local percentage_str = string.match(output, "(%d+)%%")
    local percentage = tonumber(percentage_str)
    if percentage > 80 then
        icon = ''
    elseif percentage > 60 then
        icon = ''
    elseif percentage > 40 then
        icon = ''
    elseif percentage > 20 then
        icon = ''
    else
        icon = ''
    end
    w:set_text(output .. " " .. icon)
    fh:close()
end

--- Create a volume widget
function batterywidget.new()
    local w = textbox()
    local timeout = 20

    function w._private.update()
        update(w)
        return true -- Continue the timer
    end
    local t = timer.weak_start_new(timeout, w._private.update)
    t:emit_signal("timeout")
    return w
end

function batterywidget.mt:__call()
    return batterywidget.new()
end

return setmetatable(batterywidget, batterywidget.mt)

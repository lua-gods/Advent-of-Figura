local Day = require("libraries.Day")

---@class Calendar
---@field days table<integer|"fallback", Day>
local DayManager = {}
DayManager.__index = DayManager

function DayManager.new()
    local self = setmetatable({}, DayManager)
    self.days = {}
    return self
end

---@param name integer|"fallback"
function DayManager:newDay(name)
    local day = Day.new()
    self.days[name] = day
    return day
end

---@param name integer|"fallback"
---@return Day
function DayManager:getDay(name)
    return self.days[name]
end

---@return Day
function DayManager:today()
    local day = DATE or client.getDate().day
    return self.days[day] or self.days.fallback
end

return DayManager.new()
local Day = require("libraries.Day")

---@class Calendar
---@field private days table<integer|"fallback", Day>
local Calendar = {}
Calendar.__index = Calendar

function Calendar.new()
    local self = setmetatable({}, Calendar)
    self.days = {}
    return self
end

---@param name string
---@param number integer|"fallback"
function Calendar:newDay(name, number)
    local day = Day.new(name)
    self.days[number] = day
    return day
end

---@param number integer|"fallback"
---@return Day
function Calendar:byDate(number)
    return self.days[number] or self.days.fallback
end

---@param name string
---@return Day
function Calendar:byName(name)
    for _, day in pairs(self.days) do
        if day.name == name then
            return day
        end
    end
    return self.days.fallback
end

---@return Day
function Calendar:today()
    return self:byDate(client.getDate().day)
end

return Calendar.new()
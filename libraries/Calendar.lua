local Day = require("libraries.Day")
local order = require("libraries.day_order")

---@class Calendar
---@field private days table<string|"fallback", Day>
local Calendar = {}
Calendar.__index = Calendar

function Calendar.new()
    local self = setmetatable({}, Calendar)
    self.days = {}
    return self
end

---@param name string
function Calendar:newDay(name)
    local day = Day.new(name)
    self.days[name] = day
    return day
end

---@param number integer|"fallback"
---@return Day?
function Calendar:byDate(number)
    return order[number] and self.days[order[number]]
end

---@param name string
---@return Day?
function Calendar:byName(name)
    return self.days[name]
end

function Calendar:getFallback()
    return self.days.fallback
end

---@return Day
function Calendar:today()
    return self:byDate(client.getDate().day)
end

return Calendar.new()
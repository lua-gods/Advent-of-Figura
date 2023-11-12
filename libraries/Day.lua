---@class Day
local Day = {}
Day.__index = Day

function Day.new()
    local self = setmetatable({}, Day)
    return self
end

---@param skull Skull
function Day:init(skull) end

---@param skull Skull
function Day:tick(skull) end

---@param skull Skull
---@param delta number
function Day:render(skull, delta) end

---@param skull Skull
function Day:exit(skull) end

---@param skull Skull
function Day:punch(skull) end

return Day
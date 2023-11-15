---@class Day
---@field name string
local Day = {}
Day.__index = Day

---@param name string
function Day.new(name)
    local self = setmetatable({}, Day)
    self.name = name
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
---@param puncher Player
function Day:punch(skull, puncher) end

---@param skulls Skull[]
function Day:globalTick(skulls) end

return Day
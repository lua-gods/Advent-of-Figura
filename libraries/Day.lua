local deepCopy = require("libraries.deep_copy")

---@class Day
---@field name string
---@field worn_parts ModelPart[]
local Day = {}
Day.__index = Day

---@param name string
function Day.new(name)
    local self = setmetatable({}, Day)
    self.name = name
    self.worn_parts = {}
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
function Day:globalInit(skulls) end

---@param skulls Skull[]
function Day:globalExit(skulls) end

---@param skulls Skull[]
function Day:globalTick(skulls) end

---@param entity Entity
---@return ModelPart[]? to_show
function Day:wornRender(entity) end

---These parts render when the head is worn on an entity. Each part is hidden and shown during skull render, so prefer to use minimal parts.
---Provided parts are deep copied.
---@param part ModelPart
---@return ModelPart copy
function Day:addWornPart(part)
    local copy = deepCopy(part)
    copy:visible(true)
    models.model.Skull:addChild(copy)
    copy:setParentType("SKULL")
    self.worn_parts[#self.worn_parts + 1] = copy
    return copy
end

return Day
local deepCopy = require("libraries.deep_copy")

---@class Day
---@field name string
---@field item_part ModelPart?
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

------ PER-SKULL
---@param skull Skull
function Day:init(skull) end

---@param skull Skull
function Day:tick(skull) end

---@param skull Skull
---@param delta number
function Day:render(skull, delta) end

---@param skull Skull
function Day:exit(skull) end

------ PER-DAY
---@param skulls Skull[]
function Day:globalInit(skulls) end

---@param skulls Skull[]
function Day:globalTick(skulls) end

---@param skulls Skull[]
---@param delta number
function Day:globalRender(skulls, delta) end

---@param skulls Skull[]
function Day:globalExit(skulls) end

------ HELMET ITEM
---@param entity Entity
function Day:wornInit(entity) end

---@param entity Entity
function Day:wornTick(entity) end

---@param entity Entity
---@param delta number
---@return ModelPart[]? to_show
function Day:wornRender(entity, delta) end

---@param entity Entity
function Day:wornExit(entity) end

------ OTHER
---@param skull Skull
---@param puncher Player
function Day:punch(skull, puncher) end

---These parts render when the head is worn on an entity. Each part is hidden and shown during skull render, so prefer to use minimal parts.
---Provided parts are deep copied.
---@param part ModelPart
---@return ModelPart copy
function Day:addWornPart(part)
    local copy = deepCopy(part)
    copy:visible(false)
    models.model.Skull:addChild(copy)
    copy:setParentType("SKULL")
    self.worn_parts[#self.worn_parts + 1] = copy
    return copy
end

---@param part ModelPart
---@return ModelPart copy
function Day:setItemPart(part)
    local copy = deepCopy(part)
    copy:visible(false)
    models.model.Skull:addChild(copy)
    copy:setParentType("SKULL")
    self.item_part = copy
    return copy
end

return Day
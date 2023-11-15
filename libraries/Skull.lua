local deepCopy = require("libraries.deep_copy")

local facing_rots = {
    north = 0,
    south = 8,
    east = 4,
    west = 12
}
local facing_offsets = {
    south = vec(0,0.25,-0.25),
    east = vec(-0.25,0.25,0),
    north = vec(0,0.25,0.25),
    west = vec(0.25,0.25,0)
}

---@class Skull
---@field id string
---@field pos Vector3
---@field offset Vector3
---@field render_pos Vector3 pos + offset
---@field rot number
---@field renderer SkullRenderer
---@field is_wall_head boolean
---@field day Day
---@field data table
---@field private initialized boolean
local Skull = {}
Skull.__index = Skull

---@param blockstate BlockState
---@param renderer SkullRenderer
function Skull.new(blockstate, renderer, day)
    local self = setmetatable({}, Skull)
    self.id = blockstate:getPos():toString()
    self.is_wall_head = not not blockstate.properties.facing
    self.offset = self.is_wall_head and facing_offsets[blockstate.properties.facing] or vec(0,0,0)
    self.render_pos = blockstate:getPos():add(self.offset)
    self.pos = blockstate:getPos()
    self.rot = (blockstate.properties.rotation or facing_rots[blockstate.properties.facing]) * 22.5
    self.renderer = renderer
    self.day = day
    self.data = {}
    return self
end

---Adds the given part to the skull. The part will be removed when the skull resets.
---The part will be offset by the skull's render position and rotation. (self.render_pos * 16, -self.rot)
---Specifying a parent will add the part as a child of the parent, with no offset.
---@param part ModelPart
---@param parent? ModelPart
---@return ModelPart
function Skull:addPart(part, parent)
    local copy = deepCopy(part)
    copy:pos(parent and vec(0,0,0) or self.render_pos * 16):rot(0, parent and 0 or -self.rot, 0):visible(true)
    copy:light(world.getBlockLightLevel(self.pos), world.getSkyLightLevel(self.pos))
    if parent then
        parent:addChild(copy)
    else
        self.renderer:addPart(copy)
    end
    return copy
end

function Skull:init()
    if self.day.init then
        self.day:init(self)
    end
end

function Skull:tick()
    if self.day.tick then
        self.day:tick(self)
    end
end

---@param delta number
function Skull:render(delta)
    if self.day.render then
        self.day:render(self, delta)
    end
end

function Skull:exit()
    if self.day.exit then
        self.day:exit(self)
    end
end

---@param puncher Player
function Skull:punch(puncher)
    if self.day.punch then
        self.day:punch(self, puncher)
    end
end

function Skull:isActive()
    return self.initialized
end

---@param active boolean
function Skull:setActive(active)
    self.initialized = active
end

function Skull:reset()
    if self:isActive() then
        self:exit()
    end
    self.data = {}
    self:setActive(false)
    self.renderer:reset()
    self.parts = {}
end

function Skull:remove()
    self:reset()
end

return Skull
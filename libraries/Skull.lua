local deepCopy = require("libraries.deep_copy")

local facing_rots = {
    north = 0,
    south = 8,
    east = 4,
    west = 12
}
local facing_offsets = {
    south = vec(0,-0.25,0.25),
    east = vec(0.25,-0.25,0),
    north = vec(0,-0.25,-0.25),
    west = vec(-0.25,-0.25,0)
}

---@class Skull
---@field id string
---@field pos Vector3
---@field render_pos Vector3
---@field rot number
---@field renderer SkullRenderer
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
    self.render_pos = blockstate:getPos():sub(blockstate.properties.facing and facing_offsets[blockstate.properties.facing] or vec(0,0,0))
    self.pos = blockstate:getPos()
    self.rot = (blockstate.properties.rotation or facing_rots[blockstate.properties.facing]) * 22.5
    self.renderer = renderer
    self.day = day
    self.data = {}
    return self
end

---@param part ModelPart
---@return ModelPart
function Skull:addPart(part)
    local copy = deepCopy(part)
    copy:pos(self.render_pos*16):rot(0,-self.rot,0):visible(true)
    self.renderer:addPart(copy)
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
    self:exit()
    self.data = {}
    self.initialized = false
    self.renderer:reset()
    self.parts = {}
end

function Skull:remove()
    self:reset()
end

return Skull
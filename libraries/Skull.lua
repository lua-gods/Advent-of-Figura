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
---@field type string
---@field rot number
---@field initialized boolean
---@field parts ModelPart[]
---@field renderer SkullRenderer
---@field day Day
---@field data table
local Skull = {}
Skull.__index = Skull

---@param blockstate BlockState
---@param renderer SkullRenderer
function Skull.new(blockstate, renderer, day)
    local self = setmetatable({}, Skull)
    self.id = blockstate:getPos():toString()
    self.pos = blockstate:getPos() - (blockstate.properties.facing and facing_offsets[blockstate.properties.facing] or vec(0,0,0))
    self.rot = (blockstate.properties.rotation or facing_rots[blockstate.properties.facing]) * 22.5
    self.renderer = renderer
    self.day = day
    self.parts = {}
    self.data = {}
    return self
end

---@param part ModelPart
---@return ModelPart
function Skull:addPart(part)
    local copy = deepCopy(part)
    copy:pos(self.pos*16):rot(0,self.rot,0):visible(true)
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

function Skull:punch()
    if self.day.punch then
        self.day:punch(self)
    end
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
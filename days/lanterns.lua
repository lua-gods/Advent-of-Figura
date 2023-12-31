local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("lanterns")

local LANTERN_PART = models.lantern.Lantern
local MAX_LANTERNS = 10

---@class Lantern
---@field part ModelPart
---@field pos Vector3
local Lantern = {}
Lantern.__index = Lantern

---@param skull Skull
function Lantern.new(skull)
    local self = setmetatable({}, Lantern)
    self.part = skull:addPart(LANTERN_PART)
    self.pos = skull.pos
    return self
end

function Lantern:tick()
    self.pos = self.pos + vec(0, 0.01, 0) + rng.vec3().x_z * 0.01
    self.part:pos(self.pos * 16)
end

---@param other Lantern
function Lantern:collide(other)
    local diff = self.pos - other.pos
    if (diff):length() < 0.5 then
        self.pos = self.pos + diff:normalize() * 0.05
    end
end

function day:init(skull)
    skull.data.lanterns = {}
    for i = 1, MAX_LANTERNS do
        skull.data.lanterns[i] = Lantern.new(skull)
    end
end

function day:tick(skull)
    for i = 1, MAX_LANTERNS do
        skull.data.lanterns[i]:tick()
        for j = 1, MAX_LANTERNS do
            if i ~= j then
                skull.data.lanterns[i]:collide(skull.data.lanterns[j])
            end
        end
    end
end
local LSH = require("libraries.LSH")
local Boid = require("libraries.Boid")

---@class BoidManager
---@field boids Boid[]
---@field lsh LSH
---@field target Vector3?
local BoidManager = {}
BoidManager.__index = BoidManager

function BoidManager.new()
    local self = setmetatable({}, BoidManager)
    self.boids = {}
    self.lsh = LSH.new(50, 3)
    return self
end

---@param boid Boid
function BoidManager:addBoid(boid)
    self.boids[#self.boids+1] = boid
    self.lsh:addBoid(boid)
end

---@param pos Vector3
---@return Boid
function BoidManager:newBoid(pos)
    local boid = Boid.new()
    boid.pos = pos
    self:addBoid(boid)
    return boid
end

function BoidManager:removeBoid(boid)
    for i = 1, #self.boids do
        if self.boids[i] == boid then
            table.remove(self.boids, i)
            return
        end
    end
end

function BoidManager:clear()
    self.boids = {}
    self.lsh:clear()
end

---@param target Vector3
function BoidManager:setTarget(target)
    self.target = target
end

function BoidManager:tick()
    self.lsh:clear()
    for i = 1, #self.boids do
        self.lsh:addBoid(self.boids[i])
    end
    for i = 1, #self.boids do
        local boid = self.boids[i]
        local neighbors = self.lsh:getNeighbors(boid.pos)
        boid:tick(neighbors, self.target)
    end
end

return BoidManager
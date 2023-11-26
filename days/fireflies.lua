local Calendar = require("libraries.Calendar")
local Boid = require("libraries.Boid")

---@class Day.Fireflies: Day
---@field n_boids integer
local day = Calendar:newDay("fireflies")
day.n_boids = 0

local MAX_FIREFLIES = 20
local GLOBAL_MAX = 80

---@param skull Skull
function day:init(skull)
    skull.data.boids = {}
    skull.data.particles = {}
    if day.n_boids > GLOBAL_MAX then
        return
    end
    for i = 1, MAX_FIREFLIES do
        local boid = Boid.new()
        boid.pos = skull.pos + rng.vec3()
        boid.vel = rng.vec3() * 0.1
        skull.data.boids[i] = boid
        skull.data.particles[i] = particles["totem_of_undying"]:pos(boid.pos):lifetime(100000):scale(0.4):spawn()
    end
    self.n_boids = self.n_boids + MAX_FIREFLIES
end

---@param skull Skull
function day:tick(skull)
    for i = 1, #skull.data.boids do
        local boid = skull.data.boids[i]
        boid:tick(skull.pos)
    end
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)
    for i = 1, #skull.data.boids do
        local boid = skull.data.boids[i]
        local pos = boid:getPos(delta)
        skull.data.particles[i]:pos(pos)
    end
end

---@param skull Skull
function day:exit(skull)
    for i = 1, #skull.data.particles do
        skull.data.particles[i]:remove()
    end
    for i = 1, #skull.data.boids do
        skull.data.boids[i]:remove()
    end
    self.n_boids = self.n_boids - MAX_FIREFLIES
end

---@param skulls Skull[]
function day:globalTick(skulls)

end

---@param skulls Skull[]
function day:globalInit(skulls)

end

---@param skulls Skull[]
function day:globalExit(skulls)

end

local Calendar = require("libraries.Calendar")
local BoidManager = require("libraries.BoidManager")

local day = Calendar:newDay("boids")

---@param skull Skull
function day:init(skull)
    skull.data.manager = BoidManager.new()
    skull.data.models = {}
    for i = 1, 100 do
        local boid = skull.data.manager:newBoid(skull.pos + rng.vec3() * 5)
        boid.vel = rng.vec3() * 0.001
        skull.data.models[i] = skull:addPart(models.boids.boid):scale(0.3)
    end
    skull.data.manager:setTarget(skull.pos + vec(0, 4, 0))
end

---@param skull Skull
function day:tick(skull)
    skull.data.manager:tick()
end

---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)

end

---@param skull Skull
---@param delta number
function day:render(skull, delta)
    local boids = skull.data.manager.boids
    for i = 1, #boids do
        local boid = boids[i]
        skull.data.models[i]:pos(boid:getPos(delta) * 16 + vec(-8,0,-8))
        skull.data.models[i]:rot(boid:getRot(delta))
    end
end

---@param skull Skull
function day:exit(skull)

end

---@param skulls Skull[]
function day:globalInit(skulls)

end

---@param skulls Skull[]
function day:globalTick(skulls)

end

---@param skulls Skull[]
---@param delta number
function day:globalRender(skulls, delta)

end

---@param skulls Skull[]
function day:globalExit(skulls)

end

---@param entity Entity
function day:wornInit(entity)

end

---@param entity Entity
function day:wornTick(entity)

end

---@param entity Entity
---@param delta number
function day:wornRender(entity, delta)

end

---@param entity Entity
function day:wornExit(entity)

end
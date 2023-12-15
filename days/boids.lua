local Calendar = require("libraries.Calendar")
local BoidManager = require("libraries.BoidManager")

local w = 8
local h = 8
local ITERATIONS = 16

local GREEN = vec(0,1,0,1)
local DARK_GREEN = vec(0,0.5,0,1)
local TRANSPARENT = vec(0,0,0,0)

local function greenIter()
    return DARK_GREEN
end

local function iterCreator(old, i)
    return function (clr, x, y)
        local old_pixel = old:getPixel(x, y)
        if (old_pixel ~= TRANSPARENT) then
            if math.random() > 0.1 then
                return GREEN * (((i / 2) / ITERATIONS) + 0.5)
            else
                return TRANSPARENT
            end
        else
            return TRANSPARENT
        end
    end
end

local texture0 = textures:newTexture("wobble0", w, h)
texture0:applyFunc(0, 0, w, h, greenIter)

local texture_list = {
    [0] = texture0,
}

for i = 1, ITERATIONS do
    local texture = textures:newTexture("wobble" .. i, w, h)
    texture:applyFunc(0, 0, w, h, iterCreator(texture_list[i - 1], i))
    texture_list[i] = texture
end

local day = Calendar:newDay("boids")
local boid_models = {}

local manager = BoidManager.new()

---@param skull Skull
function day:init(skull)
    skull.data.my_boids = {}
    skull.data.seed = math.random() * 10000

    for i = 1, 20 do
        local boid = manager:newBoid(skull.pos + rng.vec3().x_z:normalize() * 50 + rng.vec3() * 20 + vec(0, 50, 0))
        boid.vel = rng.vec3()
        boid_models[boid] = skull:addPart(models.boids.boid):scale(0.8)
        skull.data.my_boids[i] = boid
    end
    manager:setTarget(skull.pos + vec(0, 4, 0))

    skull.data.copies = {}
    local base = skull:addPart(models:newPart("piv"))
    for i = 1, ITERATIONS do
        local copy = models.boids.moss.cube:copy("wobble" .. i)
        base:addChild(copy)
        copy:setPrimaryTexture("CUSTOM", texture_list[i - 1])
        copy:scale(1 + (i * 0.005))
        skull.data.copies[#skull.data.copies+1] = copy
    end

    skull.data.food_orbs = {}
end

---@param skull Skull
function day:tick(skull)
    for i = 1, #manager.boids do
        local boid = manager.boids[i]
        local pos = boid.pos
        if (pos - skull.pos):lengthSquared() < 3^2 then
            skull.data.food_orbs[#skull.data.food_orbs+1] = {
                time = 0,
                particle = particles["end_rod"]:pos(skull.pos + vec(0.5, 0.5, 0.5) + rng.vec3() * 0.5):lifetime(999):color(vec(rng.float(0,0.2),rng.float(0.5,1),rng.float(0,0.2))):spawn(),
                target = boid,
                vel = rng.vec3() * 0.05
            }
        end
    end

    for i = #skull.data.food_orbs, 1, -1 do
        local orb = skull.data.food_orbs[i]
        orb.time = orb.time + 1
        if orb.time > 400 then
            particles["falling_water"]:pos(orb.particle:getPos()):spawn()
            orb.particle:remove()
            table.remove(skull.data.food_orbs, i)
        else
            local pos = orb.particle:getPos()
            orb.vel = orb.vel + (orb.target.pos - pos):normalize() * 0.02
            orb.particle:velocity(orb.vel)
            if (pos - orb.target.pos):lengthSquared() < 2 then
                particles["falling_water"]:pos(pos):spawn()
                orb.particle:remove()
                table.remove(skull.data.food_orbs, i)
            end
        end
    end
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)
    local time = client.getSystemTime() / 50
    for i = 1, #skull.data.copies do
        local v = 0.3 + (math.sin(skull.data.seed + (time / 2 + (i * 0.3))) - 0.5) * 0.2
        skull.data.copies[i]:pos(v * 0.2, v, v * 0.2)
    end
end

---@param skull Skull
function day:exit(skull)
    for i = 1, #skull.data.food_orbs do
        skull.data.food_orbs[i].particle:remove()
    end
    for i = 1, #skull.data.my_boids do
        manager:removeBoid(skull.data.my_boids[i])
    end
end

---@param skulls Skull[]
function day:globalInit(skulls)

end

---@param skulls Skull[]
function day:globalTick(skulls)
    manager:tick()
end

---@param skulls Skull[]
---@param delta number
function day:globalRender(skulls, delta)
    local boids = manager.boids
    for i = 1, #boids do
        local boid = boids[i]
        boid_models[boid]:pos(boid:getPos(delta) * 16 + vec(-8,0,-8))
        boid_models[boid]:rot(boid:getRot(delta))
    end
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
local Calendar = require("libraries.Calendar")
local BoidManager = require("libraries.BoidManager")

---@class Day.Fireflies2: Day
local day = Calendar:newDay("fireflies")
day.n_boids = 0

day:setItemPart(models.boids.frog)
day:addWornPart(models.boids.frog)

local FOLLOWERS_PER_LEADER = 20
local MAX_FIREFLIES = 10
local GLOBAL_MAX = 100

local manager = BoidManager.new({
    max_speed = 0.1,
    desired_separation = 3,
    neighbor_dist = 3,
    alignment_weight = 2.5,
    cohesion_weight = 2.0,
    separation_weight = 4.5,
    seek_weight = 1,
})

local followers = {}
---@param skull Skull
function day:init(skull)
    local frog = skull:addPart(models.boids.frog)
    frog:pos(frog:getPos() + vec(0,0.5,0))
    skull.data.frog = frog

    skull.data.boids = {}
    skull.data.particles = {}
    if day.n_boids > GLOBAL_MAX then
        return
    end
    for i = 1, MAX_FIREFLIES do
        if day.n_boids > GLOBAL_MAX then
            break
        end
        local boid = manager:newBoid(skull.pos + rng.vec3() * 5 + vec(0,5,0))
        boid.vel = rng.vec3() * 0.1
        skull.data.boids[i] = boid
        followers[boid] = {}
        for j = 1, FOLLOWERS_PER_LEADER do
            local follower = particles["end_rod"]:pos(boid.pos + rng.vec3() * 20):physics(false):lifetime(300000):scale(0):spawn()
            followers[boid][j] = {
                particle = follower,
                velocity = rng.vec3() * 0.01,
                offset = rng.vec3() * 1
            }
        end
    end
    day.n_boids = day.n_boids + #skull.data.boids

    skull.data.frog_target = rng.of(skull.data.boids)
    skull.data.swing_duration = 0
    skull.data.extending = false
    skull.data.retracting = false
    skull.data.frog_rot = vec(0,0,0)
    skull.data._frog_rot = vec(0,0,0)
    skull.data.puff = 0

    manager:setTarget(skull.pos + vec(0, 4, 0))
end

local function smooth(t)
    return 1 - math.pow(1 - t, 3)
end

local TIME_TO_SWING = 8

function day:tick(skull)
    if TIME % 10 == 0 and math.random() > 0.9 then
        skull.data.frog_target = rng.of(skull.data.boids)
        skull.data.swing_duration = 0
        skull.data.extending = true
        skull.data.retracting = false
    end

    if skull.data.extending then
        sounds["entity.frog.tongue"]:pos(skull.pos):pitch(1 + skull.data.swing_duration / TIME_TO_SWING):play()
        skull.data.swing_duration = skull.data.swing_duration + 1
        if skull.data.swing_duration == TIME_TO_SWING then
            skull.data.extending = false
            skull.data.retracting = true
            sounds["entity.frog.tongue"]:pos(skull.pos):play()
        elseif skull.data.swing_duration == TIME_TO_SWING - 5 then
            local pos = skull.pos + vec(0.5, 0.5, 0.5)
            skull.data.frog_target.vel = skull.data.frog_target.vel - (skull.data.frog_target.pos - pos):normalize() * 16
            local child = followers[skull.data.frog_target]
            for j = 1, #child do
                child[j].velocity = child[j].velocity - (skull.data.frog_target.pos - pos):normalize() * 0.3
            end
        end
    elseif skull.data.retracting then
        sounds["entity.frog.tongue"]:pos(skull.pos):pitch(1 + skull.data.swing_duration / TIME_TO_SWING):play()
        skull.data.swing_duration = skull.data.swing_duration - 1
        if skull.data.swing_duration == 0 then
            skull.data.retracting = false
        end
    end

    for i = #skull.data.boids, 1, -1 do
        local boid = skull.data.boids[i]
        for j = #followers[boid], 1, -1 do
            local child = followers[boid][j]
            local pos = child.particle:getPos()
            if (pos - (skull.pos + vec(0.5, 0.5, 0.5))):lengthSquared() < 1^2 then
                sounds["entity.frog.eat"]:pos(skull.pos):play()
                for _ = 1, 5 do
                    particles["item rotten_flesh"]:pos(pos + rng.vec3() * 0.1):scale(0.25):velocity(rng.vec3() * 0.1):spawn()
                end
                child.particle:pos(skull.pos + vec(0.5, 3.5, 0.5) + rng.vec3():normalize() * 32)
                skull.data.puff = math.min(skull.data.puff + 1, 20)
            end
        end
    end

    if skull.data.frog_target then
        local rot = utils.dirToAngle(skull.data.frog_target.pos - skull.pos)
        skull.data._frog_rot = skull.data.frog_rot
        skull.data.frog_rot = math.lerpAngle(skull.data.frog_rot, vec(-rot.x * 0.1, rot.y + 180, 0), 0.2)
    end

    skull.data.frog.croaking_body:scale(1 + skull.data.puff / 20)
    skull.data.puff = math.max(skull.data.puff - 0.1, 0)
end

function day:exit(skull)
    day.n_boids = day.n_boids - #skull.data.boids
    for i = 1, #skull.data.boids do
        for j = 1, #followers[skull.data.boids[i]] do
            followers[skull.data.boids[i]][j].particle:remove()
        end
        followers[skull.data.boids[i]] = nil
        manager:removeBoid(skull.data.boids[i])
    end
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)
    for boid, particle in pairs(skull.data.particles) do
        particle:pos(boid:getPos(delta))
    end

    if skull.data.frog_target then
        local rot = utils.dirToAngle(skull.data.frog_target.pos - skull.pos)
        local diff = (skull.data.frog_target.pos - skull.pos):length()
        skull.data.frog:rot(math.lerpAngle(skull.data._frog_rot, skull.data.frog_rot, delta))
        if skull.data.swing_duration > 0 then
            local offset = (skull.data.extending or skull.data.retracting) and (skull.data.swing_duration + (skull.data.retracting and -delta or delta)) or 0
            offset = smooth(offset / TIME_TO_SWING)
            skull.data.frog.head:rot(-rot.x * 0.9 * offset, 0, 0)
            skull.data.frog.head.tongue:scale(1,1,offset * 2.5 * diff):rot(0.9 * offset, 0, 0)
        else
            skull.data.frog.head.tongue:scale(1,1,1)
        end

        local angular_velocity = math.shortAngle(skull.data._frog_rot.y, skull.data.frog_rot.y)
        skull.data.frog.left_leg:rot((math.sin(TIME / 8)) * math.clamp(angular_velocity, -5, 5) * 20 - 10, 0, 0)
        skull.data.frog.right_leg:rot((math.cos(TIME / 8)) * math.clamp(angular_velocity, -5, 5) * 20 - 10, 0, 0)
        skull.data.frog.left_arm:rot((math.cos(TIME / 8)) * math.clamp(angular_velocity, -5, 5) * 20 - 10, 0, 0)
        skull.data.frog.right_arm:rot((math.sin(TIME / 8)) * math.clamp(angular_velocity, -5, 5) * 20 - 10, 0, 0)
    end
end

local function map(x)
    if x < 0.5 then
        return 2 * x * x
    else
        return 1 - 2 * (1 - x) * (1 - x)
    end
end

---@param skulls Skull[]
function day:globalTick(skulls)
    manager:tick()
    local i = 1
    for boid, children in pairs(followers) do
        i = i + 1
        local pos = boid:getPos(1)
        rng.seed(TIME)
        for j = 1, #children do
            local child = children[j]
            child.velocity = (child.velocity + (pos - (child.particle:getPos() + child.offset)):normalize() * 0.008) * 0.98
            child.particle:velocity(child.velocity):color(math.lerp(vec(1,1,0), vec(0.2,0.2,0.2), map(math.sin((TIME + j * 2 + i * 2) * 0.1) * 0.5 + 0.5))):scale(math.lerp(child.particle:getScale(), math.sin(TIME * 0.1 + i * 0.1) * 0.1 + 0.4, 0.1))
        end
    end
end
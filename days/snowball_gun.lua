local Calendar = require("libraries.Calendar")
local tween = require("libraries.GNTweenLib")

local day = Calendar:newDay("snowball_gun")

---@param skull Skull
function day:init(skull)
    skull:addPart(models.snowball_gun.Base)
    skull.data.gun = skull:addPart(models.snowball_gun.Gun)
    skull.data.balls = {}
end

local ACTIVATION_RANGE = 2^2

---@class Snowball
---@field pos Vector3
---@field vel Vector3
---@field particle Particle
local Snowball = {}
Snowball.__index = Snowball

function Snowball.new(pos, vel, particle)
    local self = setmetatable({}, Snowball)
    self.pos = pos
    self.vel = vel
    self.particle = particle:pos(pos):velocity(vel)
    self.alive = true
    return self
end

local TICK_GRAVITY = 9.8 / 20 / 20
function Snowball:tick()
    self.vel = self.vel * 0.99
    self.vel = self.vel - vec(0, TICK_GRAVITY, 0)
    self.particle:velocity(self.vel)

    if math.random() > 0.99 then
        particles["falling_water"]:pos(self.pos):velocity(self.vel):scale(0.5):lifetime(rng.float(10, 30)):spawn()
    end

    self.pos = self.particle:getPos()
    local block = world.getBlockState(self.pos + self.vel)
    if not block:isAir() and not block.id:find("head") then
        self.alive = false
    end
end

function Snowball:remove()
    self.particle:remove()
    for i = 1, 5 do
        particles["item snowball"]:pos(self.pos):velocity(rng.vec3() * 0.1):scale(0.5):lifetime(rng.float(100, 150)):spawn()
    end
    sounds["block.powder_snow.place"]:pos(self.pos):pitch(rng.float(0.9,1.1)):volume(0.3):attenuation(1.5):subtitle("Snowball hits"):play()
end

local function dirToAngle(dir)
    return vec(-math.deg(math.asin(dir.y)), math.deg(math.atan2(dir.x, dir.z)), 0)
end

local function aim(skull, target_pos)
    local dir = (target_pos - skull.render_pos):normalize()
    local angle = dirToAngle(dir)
    tween.tweenFunction(skull.data.gun:getRot(), angle, 2, "outExpo", function (rot)
        skull.data.gun:rot(rot)
    end, nil, "SnowballGunAim"..skull.id)
end

local function shoot(skull)
    for i = 1, 3 do
        particles["poof"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):velocity(rng.vec3() * 0.1):scale(rng.float(0.8,1.2)):lifetime(rng.float(3, 10)):spawn()
    end
    sounds["entity.snow_golem.shoot"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(rng.float(0.4,0.7)):volume(0.1):attenuation(1.5):subtitle("Snowball shoots"):play()
    local particle = particles["item snowball"]
    particle:scale(rng.float(0.8,1.2)):lifetime(200):spawn()
    local matrix = skull.data.gun:partToWorldMatrix()
    local ball = Snowball.new(matrix:apply(0,12,8), vec(0,0.2,0) - matrix:applyDir(0,0,-1) * 8 + rng.vec3() * 0.05, particle)
    skull.data.balls[#skull.data.balls+1] = ball
end

---@param skull Skull
function day:tick(skull)
    for _, player in next, world.getPlayers() do
        if (player:getPos() - skull.pos):lengthSquared() < ACTIVATION_RANGE then
            local _, target_pos = player:getTargetedBlock()
            aim(skull, target_pos)
            shoot(skull)
            break
        end
    end
    for i = #skull.data.balls, 1, -1 do
        local ball = skull.data.balls[i]
        ball:tick()
        if not ball.alive then
            ball:remove()
            table.remove(skull.data.balls, i)
        end
    end
end

---@param skull Skull
function day:punch(skull)

end

---@param skull Skull
---@param delta number
function day:render(skull, delta)

end

---@param skull Skull
function day:exit(skull)
    for i = 1, #skull.data.balls do
        skull.data.balls[i]:remove()
    end
end
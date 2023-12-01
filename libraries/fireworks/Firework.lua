---@class Firework
---@field pos Vector3
---@field vel Vector3
---@field private ticking boolean
---@field protected blahaj_blast fun(pos: Vector3)
---@field protected time integer
local Firework = {}
Firework.__index = Firework

---@param pos Vector3
---@param blast fun(pos: Vector3)
function Firework.new(pos, vel, blast)
    local self = setmetatable({}, Firework)
    self.pos = pos
    self.vel = vel
    self.blahaj_blast = blast
    self.ticking = true
    self.time = 0
    return self
end

function Firework:tick()
    if not self.ticking then return end
    self.time = self.time + 1
    if self.time >= 50 and math.random() > 0.9 then
        self:blast()
    end
    self:move()
end

function Firework:move()
    self.pos = self.pos + self.vel
    self.vel = self.vel + vec(rng.float(-0.1, 0.1), rng.float(-0.01, 0), rng.float(-0.1, 0.1))
    if world.getBlockState(self.pos + self.vel * 8):hasCollision() then
        self:blast()
    end
    self:trail()
end

local MINECRAFT_SPEED_OF_SOUND = 40
function Firework:blast()
    self.blahaj_blast(self.pos)
    delay(function ()
        sounds["entity.firework_rocket.blast_far"]:pos(self.pos):attenuation(30):volume(0.5):pitch(0.9):subtitle("Firework detonates"):play()
    end, (self.pos - client:getCameraPos()):length() / MINECRAFT_SPEED_OF_SOUND)
    self.ticking = false
end

function Firework:trail()
    particles["firework"]
    :pos(self.pos)
    :scale(rng.float(0.6,1))
    :lifetime(math.random(5,30))
    :velocity(-self.vel * rng.float(0.7,1.3))
    :color(vec(1,1,1) * rng.float(0.7,1))
    :spawn()

    if (client:getCameraPos() - self.pos):length() < 50 then
        sounds["entity.firework_rocket.launch"]
        :volume(rng.float(0.10,0.20))
        :pitch(math.max(0.2, 2 - self.time / 40))
        :pos(self.pos)
        :attenuation(3)
        :play()
    end
end

function Firework:isDead()
    return not self.ticking
end

return Firework
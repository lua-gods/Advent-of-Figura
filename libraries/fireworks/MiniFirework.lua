local Firework = require(.....".Firework")

---@class MiniFirework: Firework
local MiniFirework = {}
MiniFirework.__index = MiniFirework
setmetatable(MiniFirework, Firework)

function MiniFirework.new(...)
    local self = setmetatable(Firework.new(...), MiniFirework)
    return self
end

function MiniFirework:move()
    self.pos = self.pos + self.vel * 0.01
    self.vel = self.vel + vec(rng.float(-0.2, 0.2), rng.float(-0.01, 0), rng.float(-0.2, 0.2))
    self:trail()
end

local MINECRAFT_SPEED_OF_SOUND = 40
function Firework:blast()
    self.blahaj_blast(self.pos)
    delay(function ()
        sounds["entity.firework_rocket.blast_far"]:pos(self.pos):volume(0.1):pitch(rng.float(1.8,2)):subtitle("Firework detonates"):play()
    end, (self.pos - client:getCameraPos()):length() / MINECRAFT_SPEED_OF_SOUND)
    self.ticking = false
end

function MiniFirework:trail()
    particles["firework"]
    :pos(self.pos)
    :scale(rng.float(0.02,0.03))
    :lifetime(math.random(5,30))
    :velocity(-self.vel * rng.float(0.07,0.13))
    :color(vec(1,1,1) * rng.float(0.7,1))
    :spawn()

    if (client:getCameraPos() - self.pos):length() < 50 then
        sounds["entity.firework_rocket.launch"]
        :volume(rng.float(0.01,0.005))
        :pitch(math.max(0.2, 3 - self.time / 60))
        :pos(self.pos)
        :play()
    end
end

return MiniFirework
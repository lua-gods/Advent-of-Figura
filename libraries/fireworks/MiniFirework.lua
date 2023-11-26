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

function MiniFirework:trail()
    particles["firework"]
    :pos(self.pos)
    :scale(rng.float(0.06,0.08))
    :lifetime(math.random(5,30))
    :velocity(-self.vel * rng.float(0.07,0.13))
    :color(vec(1,1,1) * rng.float(0.7,1))
    :spawn()

    if (client:getCameraPos() - self.pos):length() < 50 then
        sounds["entity.firework_rocket.launch"]
        :volume(rng.float(0.01,0.02))
        :pitch(math.max(0.2, 2.5 - self.time / 60))
        :pos(self.pos)
        :attenuation(3)
        :play()
    end
end

return MiniFirework
local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("snow_globe", 1)
local tween = require("libraries.GNTweenLib")

function day:init(skull)
    skull.data.snow_part = skull:addPart(models.snow_globe.SnowGlobe)
    skull.data.particles = {}
    skull.data.snow_level = 300
    skull.data.shake = 0
end

function day:punch(skull, puncher)
    if puncher:getHeldItem().id:find("head") then return end
    if skull.data.snow_level > 1 then
        sounds["block.powder_snow.place"]:pos(skull.pos + vec(0.5,0.5,0.5)):pitch(rng.float(0.8,1.2)):subtitle("Snow poofs"):play()
        for i = 1, 20 do
            local pos = skull.pos + vec(0.5 + rng.float(-0.2,0.2),rng.float(0.1,0.5),0.5 + rng.float(-0.2,0.2))
            skull.data.particles[#skull.data.particles+1] = particles["spit"]:color(rng.float(0.7,0.9),1,1):pos(pos):scale(rng.float(0.05,0.15)):gravity(rng.float(0.005,0.02)):lifetime(rng.float(20,80)):velocity(rng.vec3() * 0.01 + vec(0, 0.01, 0)):spawn()
            skull.data.snow_level = skull.data.snow_level - 1
        end
        skull.data.shake = .2
    end
end

function day:tick(skull)
    skull.data.snow_part.Snow:pos(0, skull.data.snow_level / 150, 0)
    if skull.data.shake > 0.05 then
        skull.data.shake = skull.data.shake * 0.5
        skull.data.snow_part:pos(skull.pos:copy():add(rng.vec3().x_z * skull.data.shake) * 16):rot(0, -skull.rot + rng.float(-skull.data.shake * 40, skull.data.shake * 40), 0)
    end
    for i = #skull.data.particles, 1, -1 do
        local particle = skull.data.particles[i]
        if not particle:isAlive() then
            table.remove(skull.data.particles, i)
            skull.data.snow_level = skull.data.snow_level + 1
        end
    end
end

function day:exit(skull)
    for i = 1, #skull.data.particles do
        skull.data.particles[i]:remove()
    end
end
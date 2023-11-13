local Calendar = require("libraries.Calendar")
local FireworkManager = require("libraries.fireworks.FireworkManager")
local variants = require("libraries.fireworks.variants")

local day = Calendar:newDay("fireworks", 24)

function day:init(skull)
    skull.data.part = skull:addPart(models.fireworks.Barrel)
    skull.data.fireworks = FireworkManager.new()
    skull.data.offset = math.floor(skull.pos.x * 3 + skull.pos.z * 5 + skull.pos.y * 7) % 50
end

function day:tick(skull)
    if (TIME + skull.data.offset) % 50 == 0 then
        skull.data.part.lid:uvPixels(8,0)
        sounds["block.barrel.open"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(1.2):volume(0.05):play()
        for i = 1, 15 do
            particles["smoke"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):velocity(rng.vec3().x_z--[[@as Vector3]] * 0.2 + vec(0,0.01,0)):gravity():scale(0.7):lifetime(rng.float(15,30)):spawn()
        end
        delay(function()
            sounds["block.barrel.close"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(1.5):volume(0.05):play()
            delay(function()
                if not skull.data.part then return end
                skull.data.part.lid:uvPixels(0,0)
            end, 4)
        end, 15)
        skull.data.fireworks:spawn(skull.render_pos + vec(0.5, 0.5, 0.5), vec(0,1,0), variants[math.random(1, #variants)])
    end
    skull.data.fireworks:tick()
end

function day:exit(skull)
    skull.data.fireworks:remove()
end
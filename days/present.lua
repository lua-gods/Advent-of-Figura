local Calendar = require("libraries.Calendar")
local FireworkManager = require("libraries.fireworks.FireworkManager")
local variants = require("libraries.fireworks.variants")

local day = Calendar:newDay("present")

local effects = {
    function(skull)
        for i = 1, 20 do
            particles["end_rod"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.1)):color(vectors.hsvToRGB(rng.float(0,1),0.5,1)):spawn()
        end
        sounds["block.note_block.bell"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):pitch(rng.float(0.5,1.5)):volume(0.5):play()
    end,
    function(skull)
        skull.data.fireworks:spawn(skull.render_pos + vec(0.5,0.5,0.5), rng.vec3():add(0,1,0):scale(0.5), rng.of(variants))
    end,
}

local model_variants = models.presents.Present:getChildren()

---@param skull Skull
function day:init(skull)
    skull.data.fireworks = FireworkManager.new()
    math.randomseed(skull.pos.x * 3 + skull.pos.z * 5 + skull.pos.y * 7)
    math.random(); math.random(); math.random()
    skull.data.effect = rng.of(effects)
    skull:addPart(rng.of(model_variants))
end

---@param skull Skull
function day:tick(skull)
    skull.data.fireworks:tick()
end

---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)
    skull.data.effect(skull)
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)

end

---@param skull Skull
function day:exit(skull)

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

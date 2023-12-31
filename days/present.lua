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
        for i = 1, 100 do
            particles["totem_of_undying"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():mul(5,1,5):add(0,1,0):normalize():scale(1):add(0,1,0)):spawn()
        end
        sounds["item.totem.use"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):pitch(rng.float(1,1.5)):volume(0.1):play()
    end,
    function(skull)
        run(function(n)
            for i = 1, 5 do
                particles["bubble"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
                particles["splash"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
                particles["rain"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
                particles["fishing"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):gravity(1):spawn()
            end
            sounds["entity.generic.swim"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):pitch(rng.float(1.5,2) - (n / 14)):volume(0.2):play()
        end, 15)
    end,
    function(skull)
        run(function(n)
            for i = 1, 5 do
                particles["bubble"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
                particles["splash"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
                particles["rain"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
                particles["fishing"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):gravity(1):spawn()
            end
            sounds["entity.generic.swim"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):pitch(rng.float(1.5,2) - (n / 14)):volume(0.2):play()
        end, 15)
    end,
    function(skull)
        sounds["entity.tnt.primed"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):pitch(rng.float(0.9,1.2)):volume(0.5):play()
        local fuse = rng.int(15,50)
        run(function(n)
            for i = 1, 5 do
                particles["smoke"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
                particles["smoke"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
            end
        end, fuse)
        delay(function ()
            particles["explosion_emitter"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
            sounds["entity.generic.explode"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):pitch(rng.float(1.5,2)):volume(0.2):play()
        end, fuse)
    end,
    function(skull)
        skull.data.fireworks:spawn(skull.render_pos + vec(0.5,0.5,0.5), rng.vec3():add(0,1,0):scale(0.5), rng.of(variants))
    end,
    function(skull)
        run(function(n)
            for i = 1, 5 do
                particles["lava"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
                particles["smoke"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
                particles["flame"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3():add(0,1,0):scale(0.2)):spawn()
            end
            sounds["block.lava.pop"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):pitch(rng.float(1.5,2) - (n / 14)):volume(0.2):play()
        end, 15)
    end,
    function(skull)
        run(function(n)
            for i = 1, 20 do
                particles["end_rod"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):lifetime(rng.float(50,500)):gravity():velocity(rng.vec3():normalize():add(0,1,0):scale(2) * math.random()):scale(0.2):spawn()
            end
            sounds["minecraft:block.amethyst_block.chime"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):pitch(rng.float(1.5,2) - (n / 14)):volume(0.2):play()
        end, 10)
    end,
    function(skull)
        run(function(n)
            for i = 1, 10 do
                particles["poof"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):lifetime(rng.float(50,400)):gravity(rng.float(0.1,0.4)):velocity(rng.vec3():normalize():add(0,1,0):scale(1) * math.random()):scale(0.2):spawn()
                particles["cloud"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):lifetime(rng.float(50,400)):gravity(rng.float(0.1,0.4)):velocity(rng.vec3():normalize():add(0,1,0):scale(1) * math.random()):scale(0.2):spawn()
                particles["snowflake"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):lifetime(rng.float(50,400)):gravity(rng.float(0.1,0.4)):velocity(rng.vec3():normalize():add(0,1,0):scale(1) * math.random()):scale(0.2):spawn()
            end
            sounds["block.snow.break"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):pitch(rng.float(1.5,2) - (n / 54)):volume(0.2):play()
        end, 40)
    end,
    function(skull)
        for i = 1, 150 do
            particles["dragon_breath"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):velocity(rng.vec3():normalize():scale(rng.float(0.1,0.2))):gravity(-0.05):lifetime(rng.float(40,80)):spawn()
        end
        sounds["entity.ender_dragon.growl"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(rng.float(0.8, 1.2)):volume(0.4):play()
    end,
    function(skull)
        run(function(n)
            for i = 1, 10 do
                particles["reverse_portal"]:pos(skull.render_pos + vec(0.5,0.5,0.5)):velocity(rng.vec3()):spawn()
            end
        end, 80)
        sounds["block.portal.ambient"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(rng.float(0.9, 1.1)):volume(0.3):play()
    end,
    function(skull)
        for i = 1, 50 do
            particles["cloud"]:color(rng.float(0.5,0.8),0,0):pos(skull.render_pos + vec(0.5, 0.5, 0.5)):velocity(rng.vec3():normalize():scale(0.1)):scale(0.3):physics():gravity(0.01):lifetime(rng.float(30,60)):spawn()
        end
        sounds["block.redstone_torch.burnout"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(rng.float(1.0, 1.5)):volume(0.2):play()
    end,
}

local model_variants = models.presents.Present:getChildren()

---@param skull Skull
function day:init(skull)
    skull.data.fireworks = FireworkManager.new()
    rng.seed(skull.pos)
    local effect, i = rng.of(effects)
    skull.data.effect = effect
    skull.data.salt = 0
    local part = skull:addPart((rng.of(model_variants)))
    rng.seed(i)
    part:color(vectors.hsvToRGB(i / #effects,0.5,1))
    part:scale(rng.float(0.9,1.1))
    skull.debugger:expose("effect", i)
    skull.debugger:expose("salt", skull.data.salt)
end

---@param skull Skull
function day:tick(skull)
    skull.data.fireworks:tick()
end

---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)
    skull.data.effect(skull)
    rng.seed(skull.pos + vec(0,0,skull.data.salt))
    skull.data.salt = skull.data.salt + 1
    skull.debugger:expose("salt", skull.data.salt)
end
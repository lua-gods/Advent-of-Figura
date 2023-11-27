local Calendar = require("libraries.Calendar")
local tween = require("libraries.GNTweenLib")

---@class Day.Jukebox: Day
---@field main Skull
---@field time integer
local day = Calendar:newDay("jukebox")

day:setItemPart(models.jukebox)

local notes = {
    [0] = { 1.26, 1.498, 1, 0.5 },
    [15] = { 1.335, 1.682 },
    [20] = { 1.26, 1.498, 1 },
    [30] = { 1, 1.26, 0.749, 0.5 },
    [45] = { 0.841 },
    [50] = { 0.749 },
    [60] = { 1.26, 1.498, 1, 0.5 },
    [75] = { 1.335, 1.682 },
    [80] = { 1.26, 1.498, 1 },
    [90] = { 1, 1.26, 0.749, 0.5 },
    [105] = { 0.841 },
    [110] = { 0.749 },
    [120] = { 1.335, 2.245, 0.944, 0.749 },
    [140] = { 1.335, 2.245, 0.944 },
    [150] = { 1.335, 1.888, 1.122, 0.749 },
    [165] = { 1.26 },
    [170] = { 1.122 },
    [180] = { 1.26, 2, 1, 0.749 },
    [200] = { 1.26, 2, 1 },
    [210] = { 1.498, 1.26, 0.749, 0.5 },
    [225] = { 1.122 },
    [230] = { 1 },
    [240] = { 1.335, 1.682, 0.667, 1 },
    [260] = { 1.335, 1.682, 0.667, 0.841 },
    [270] = { 1.682, 2, 0.667, 1 },
    [285] = { 1.498, 1.888 },
    [290] = { 1.335, 1.682 },
    [300] = { 1.26, 1.498, 1, 0.63 },
    [315] = { 1.335, 1.682 },
    [320] = { 1.26, 1.498, 1 },
    [330] = { 1, 1.26, 0.749, 0.5 },
    [345] = { 0.841 },
    [350] = { 0.749 },
    [360] = { 1.335, 1.682, 0.667, 1 },
    [380] = { 1.335, 1.682, 0.667, 0.841 },
    [390] = { 1.682, 2, 0.667, 1 },
    [405] = { 1.498, 1.888 },
    [410] = { 1.335, 1.682 },
    [420] = { 1.26, 1.498, 1, 0.63 },
    [435] = { 1.335, 1.682 },
    [440] = { 1.26, 1.498, 1 },
    [450] = { 1, 1.26, 0.749, 0.5 },
    [465] = { 0.841 },
    [470] = { 0.749 },
    [480] = { 1.335, 2.245, 0.749, 0.944 },
    [500] = { 1.335, 2.245, 0.749, 0.944 },
    [510] = { 1.682, 2.67, 1.122, 0.561 },
    [525] = { 1.335, 2.245 },
    [530] = { 1.498, 1.888, 0.749 },
    [540] = { 1.26, 2, 1, 0.63 },
    [555] = { 0.667 },
    [560] = { 0.63 },
    [570] = { 1.498, 2.52, 1, 0.5 },
    [600] = { 1.26, 2, 0.63, 0.749 },
    [615] = { 1.26, 1.498 },
    [620] = { 1, 1.26, 0.5, 0.749 },
    [630] = { 0.944, 1.498, 0.375, 0.667 },
    [645] = { 0.841, 1.335 },
    [650] = { 0.944, 1.122, 0.375, 0.561 },
    [660] = { 0.749, 1, 0.5, 0.63 },
}

---@type table<string,fun(block : BlockState): boolean?>
local instrument = {
    ["block.note_block.bass"] = function (block)
        for key, tag in pairs(block:getTags()) do
            if tag == "minecraft:mineable/axe" then
                return true
            end
        end
    end,
    ["block.note_block.snare"] = function (block)
        local id = block.id
        if id == "minecraft:sand" or id == "minecraft:gravel" then
            return true
        elseif id:sub(-16,-1) == "concrete_powder" then
            return true
        end
    end,
    ["block.note_block.hat"] = function (block)
        local id = block.id
        if id:sub(-6,-1) == "glass" then
            return true
        elseif id == "minecraft:sea_lantern" or id == "minecraft:beacon" then
            return true
        end
    end,
    ["block.note_block.bell"] = function (block) return block.id == "minecraft:gold_block" end,
    ["violin"] = function (block) return block.id == "minecraft:note_block" end,
    ["block.note_block.flute"] = function (block) return block.id == "minecraft:clay" end,
    ["block.note_block.chime"] = function (block) return block.id == "minecraft:packed_ice" end,
    ["block.note_block.xylophone"] = function (block) return block.id == "minecraft:bone_block" end,
    ["block.note_block.iron_xylophone"] = function (block) return block.id == "minecraft:iron_block" end,
    ["block.note_block.cow_bell"] = function (block) return block.id == "minecraft:soul_sand" or block.id == "minecraft:soul_soil" end,
    ["block.note_block.didgeridoo"] = function (block) return block.id:find("pumpkin") ~= nil end,
    ["block.note_block.bit"] = function (block) return block.id == "minecraft:emerald_block" end,
    ["block.note_block.banjo"] = function (block) return block.id == "minecraft:hay_block" end,
    ["block.note_block.pling"] = function (block) return block.id == "minecraft:glowstone" end,
    ["block.note_block.imitate.skeleton"] = function (block) return block.id == "minecraft:skeleton_skull" end,
    ["block.note_block.imitate.wither_skeleton"] = function (block) return block.id == "minecraft:wither_skeleton_skull" end,
    ["block.note_block.imitate.zombie"] = function (block) return block.id == "minecraft:zombie_head" end,
    ["block.note_block.imitate.creeper"] = function (block) return block.id == "minecraft:creeper_head" end,
    ["block.note_block.imitate.piglin"] = function (block) return block.id == "minecraft:piglin_head" end,
    ["block.note_block.imitate.ender_dragon"] = function (block) return block.id == "minecraft:dragon_head" end,
    ["block.note_block.guitar"] = function (block) return block.id:find("wool") ~= nil end,
    ["block.note_block.basedrum"] = function (block)
        local id = block.id  -- LMAO -GN
        if id:find("stone") or id:find("quartz") or id:find("bricks")
        or id:find("coral") or id:find("nylium") or id:find("concrete")
        or id:find("sandstone") or id:find("ore")
        or id == "minecraft:observer" or id == "minecraft:obsidian"
        or id == "minecraft:netherack"or id == "minecraft:respawn_anchor"
        or id == "minecraft:bedrock" then return true end
    end,
    ["entity.slime.squish"] = function (block) return block.id:find("slime") and true or false end,
    ["entity.villager.ambient"] = function (block) return block.id:find("lectern") and true or false end,
    ["block.anvil.land"] = function (block) return block.id:find("anvil") and true or false end
}

local function find_instrument(block)
    if block.id then
        local data = block:getEntityData()
        if data and type(data.note_block_sound) == 'string' then
            return data.note_block_sound
        end
        for key, value in pairs(instrument) do
            if value(block) then
                return key
            end
        end
    end
    return "block.note_block.harp"
end

---@param skull Skull
function day:init(skull)
    if not self.main then
        self.time = 0
        self.main = skull
    end
    skull:addPart(models.jukebox)
    skull.data.instrument = find_instrument(world.getBlockState(skull.pos:copy():sub(0,1,0)))
    skull.data.anim_time = 0
    skull.data.particles = {}
end

local UP = vec(0,1,0)
local function note(time, pos, id)
    if notes[time] then
        for i = 1, #notes[time] do
            sounds[id]:pos(pos + UP):attenuation(1.5):volume(0.7):pitch(notes[time][i]):play()
        end
        return notes[time]
    end
end

local TWO_PI = math.pi * 2
local function noteColour(pitch)
    local red = math.max(0.0, math.sin(pitch * TWO_PI) * 0.65 + 0.35)
    local green = math.max(0.0, math.sin((pitch + (1/3)) * TWO_PI) * 0.65 + 0.35)
    local blue = math.max(0.0, math.sin((pitch + (2/3)) * TWO_PI) * 0.65 + 0.35)
    return red, green, blue
end

local OFFSET = vec(0.5, 0.5, 0.5)

local function bounce(skull)
    if skull.renderer.parts[1] then
        tween.tweenFunction(skull.data.anim_time,0.25,0.2,"outBack",function(x)
            skull.data.anim_time = x --[[@as number]]
            skull.renderer.parts[1]:setScale(1/(1+x),1+x,1/(1+x))
        end,function()
            tween.tweenFunction(.25,0,0.4,"outQuad",function(x)
                skull.data.anim_time = x --[[@as number]]
                skull.renderer.parts[1]:setScale(1/(1+x),1+x,1/(1+x))
            end,nil,"JukeboxSing"..skull.id)
        end,"JukeboxSing"..skull.id)
    end
end

function day:globalInit()
    self.time = 0
end

function day:globalTick()
    self.time = (self.time + 1) % 720
end

---@param skull Skull
function day:tick(skull)
    local pitches = note(self.time, skull.pos + OFFSET, skull.data.instrument)
    if pitches then
        for i = 1, #pitches do
            local lifetime = rng.float(20, 40)
            skull.data.particles[#skull.data.particles+1] = {
                particle = particles["note"]:pos(skull.render_pos + OFFSET):velocity(rng.vec3():normalize() * 0.1 + vec(0,0.2,0)):scale(0.5):lifetime(lifetime):color(noteColour(pitches[i])):spawn(),
                lifetime = lifetime,
                max_lifetime = lifetime
            }
        end
        bounce(skull)
    end

    for i = #skull.data.particles, 1, -1 do
        local particle = skull.data.particles[i]
        particle.lifetime = particle.lifetime - 1
        particle.particle:scale(particle.lifetime / particle.max_lifetime)
        if particle.lifetime <= 0 then
            particle.particle:remove()
            table.remove(skull.data.particles, i)
        end
    end

    return pitches and true or false
end

function day:punch(skull, puncher)
    if puncher:getHeldItem().id:find("head") then return end
    bounce(skull)
    for i = 1, 32 do
        if day:tick(skull) then
            break
        end
    end
end

---@param skull Skull
function day:exit(skull)
    for i = #skull.data.particles, 1, -1 do
        skull.data.particles[i].particle:remove()
    end
end
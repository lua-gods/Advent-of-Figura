local Calendar = require("libraries.Calendar")
local tween = require("libraries.GNTweenLib")
local SkullRenderer = require("libraries.SkullRenderer")

---@class Day.Jukebox: Day
---@field main Skull
---@field time integer
---@field setters table<Skull, boolean>
local day = Calendar:newDay("jukebox")
day.setters = {}

day:setItemPart(models.jukebox)

local function toMcPitch(pitch)
    return 2 ^ ((pitch - 60) / 12)
end

local function parseString(string_representation)
    local notes = {}
    local total_time = 0
    local pattern = "(%d+),(%d+)" .. ";"

    for time_diff, note in string_representation:gmatch(pattern) do
        total_time = total_time + tonumber(time_diff)
        note = tonumber(note)

        if not notes[total_time] then
            notes[total_time] = {}
        end
        table.insert(notes[total_time], toMcPitch(note))
    end

    notes.last = total_time + 10

    return notes
end

local failed_to_add = false
local songs = {}
for i, path in next, listFiles("days.songs") do
    local song = {
        title = path:gsub("days%.songs%.",""),
        notes = parseString(require(path))
    }
    song.last = song.notes.last

    local number = song.title:match("^(%d+)_")
    if number then
        songs[tonumber(number)] = song
    else
        logJson("\n§cWarning: §r" .. song.title .. " §7wasn't added.")
        failed_to_add = true
    end
end

if failed_to_add and IS_HOST then
    logJson("\n§7The correct format is §r#_song_name§7, where §r#§7 is a signal strength.\n")
end

local song = songs[0]

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

local cache = {}
local function find_instrument(block)
    if not cache[block:toStateString()] then
        cache[block:toStateString()] = "block.note_block.harp"
        local data = block:getEntityData()
        if data and type(data.note_block_sound) == 'string' then
            cache[block:toStateString()] = data.note_block_sound
        else
            for key, value in pairs(instrument) do
                if value(block) then
                    cache[block:toStateString()] = key
                    break
                end
            end
        end
    end
    return cache[block:toStateString()]
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
    if song.notes[time] then
        for i = 1, #song.notes[time] do
            sounds[id]:pos(pos + UP):attenuation(1.5):volume(0.7):pitch(song.notes[time][i]):play()
        end
        return song.notes[time]
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
    self.time = -2
    song = songs[0]
end

local was_conflicted = {}
function day:globalTick()
    self.time = (self.time + 1) % song.last

    if next(self.setters, next(self.setters)) then
        local last = nil
        for skull, _ in pairs(self.setters) do
            local part = skull.renderer.parts[1].conflict:primaryRenderType("LINES"):primaryColor(1,0,0) --[[@as ModelPart]]
            part:pos():matrix(part:getPositionMatrix() * matrices.mat4() * 0.08)

            local other = last or next(self.setters, skull)
            local my_pos = vectors.worldToScreenSpace(skull.render_pos)
            local other_pos = vectors.worldToScreenSpace(other.render_pos)

            local side = my_pos.x < other_pos.x and true or false
            local dir_char = nil
            dir_char = my_pos.x < other_pos.x and ">" or "<"
            if math.abs(my_pos.y - other_pos.y) > math.abs(my_pos.x - other_pos.x) then
                dir_char = my_pos.y < other_pos.y and "v" or "^"
            end
            local text = side and "§7Conflict§c " .. dir_char or "§c" .. dir_char .. " §7Conflict"

            local rot = client:getCameraRot()
            part:newText("duplicate"):text(text):scale(0.2):outline(true):pos(0,12,0):alignment("CENTER"):rot(rot.x, -rot.y + skull.rot)

            was_conflicted[#was_conflicted+1] = part
            last = skull
        end
    elseif next(was_conflicted) then
        for i = 1, #was_conflicted do
            was_conflicted[i]:primaryRenderType("NONE"):removeTask()
        end
        was_conflicted = {}
    end

    self.setters = {}
end

---@param skull Skull
function day:tick(skull)
    local redstone_level = world.getRedstonePower(skull.pos)
    if redstone_level == 15 then
        return
    elseif redstone_level > 0 then
        if songs[redstone_level] and songs[redstone_level] ~= song then
            song = songs[redstone_level]
            self.setters[skull] = true
            self.time = -2
            return
        end
    end

    if self.time < 0 then
        return
    end

    skull.data.instrument = find_instrument(world.getBlockState(skull.pos:copy():sub(0,1,0)))
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

    skull.debugger:expose("instrument", skull.data.instrument)
    skull.debugger:expose("time", self.time)
    skull.debugger:expose("song", song.title)

    return pitches and true or false
end

function day:punch(skull, puncher)
    -- if puncher:getHeldItem().id:find("head") then return end
    -- selected_song = selected_song + 1
    -- if selected_song > #songs then
    --     selected_song = 1
    -- end
    -- song = songs[selected_song]
    -- self.time = 0
end

---@param skull Skull
function day:exit(skull)
    for i = #skull.data.particles, 1, -1 do
        skull.data.particles[i].particle:remove()
    end
end
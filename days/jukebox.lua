local Calendar = require("libraries.Calendar")
local tween = require("libraries.GNTweenLib")
local SkullRenderer = require("libraries.SkullRenderer")

---@class Day.Jukebox: Day
---@field main Skull
---@field time integer
---@field setters table<Skull, boolean>
---@field e_providers table<Skull, boolean>
local day = Calendar:newDay("jukebox")
day.setters = {}
day.e_providers = {}

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

    notes.last = total_time + 80

    return notes
end

local function lazyLoadNotes(path)
    local notes
    return function()
        if not notes then
            notes = parseString(require(path))
        end
        return notes
    end
end

local failed_to_add = false
local songs = {}
for i, path in next, listFiles("days.songs") do
    local song = {
        title = path:gsub("days[%.%/]songs[%.%/]", ""),
        lazy_notes = lazyLoadNotes(path)
    }

    setmetatable(song, {
        __index = function(t, key)
            if key == "notes" then
                return t.lazy_notes()
            elseif key == "last" then
                return t.lazy_notes().last
            else
                return rawget(t, key)
            end
        end
    })

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
if Calendar:now() < 17 and not IS_HOST then
    songs = { [0] = song }
end

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
    ["piano"] = function (block) return block.id == "minecraft:loom" end,
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

local e_parts = {
    include = {vectors.vec3(-1,-1,0),
        vectors.vec3(1,-1,0),

        vectors.vec3(-1,-2,0),

        vectors.vec3(-1,-3,0),
        vectors.vec3(0,-3,0),
        vectors.vec3(1,-3,0),

        vectors.vec3(-1,-4,0),

        vectors.vec3(-1,-5,0),
        vectors.vec3(0,-5,0),
        vectors.vec3(1,-5,0),},
    exclude = {
        vectors.vec3(0,-2,0),
        vectors.vec3(1,-2,0),

        vectors.vec3(0,-4,0),
        vectors.vec3(1,-4,0),

        vectors.vec3(-2,-1,0),
        vectors.vec3(-2,-2,0),
        vectors.vec3(-2,-3,0),
        vectors.vec3(-2,-4,0),
        vectors.vec3(-2,-5,0),
    }
}

local function e(pos)
    local mat = matrices.mat4()
    for i = 1, 4, 1 do
        local worthy = true
        local block = world.getBlockState(pos:copy():add(0,-1,0)).id
        for key, offset in pairs(e_parts.include) do
            local gpos = pos + mat:apply(offset)
            if world.getBlockState(gpos).id ~= block then
                worthy = false
                break
            end
        end
        for key, offset in pairs(e_parts.exclude) do
            local gpos = pos + mat:apply(offset)
            if world.getBlockState(gpos).id == block then
                worthy = false
                break
            end
        end
        if worthy then
            print("worthy")
            return true
        else
            mat:rotateY(90)
        end
    end
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
    self.e = e(skull.pos)
    self.e_providers[skull] = true
    skull.data.stress = 0
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
        tween.tweenFunction(skull.data.anim_time,0.25,0.15,"outBack",function(x)
            skull.data.anim_time = x --[[@as number]]
            skull.renderer.parts[1]:setScale(1/(1+x),1+x,1/(1+x))
        end,function()
            tween.tweenFunction(.25,0,0.5,"outSine",function(x)
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
    if not song then return end
    local redstone_level = world.getRedstonePower(skull.pos)
    local torch = skull.renderer.parts[1].jukebox.torch
    local torch_rot = torch:getRot()
    local torch_desired_rot = vec(redstone_level * 90, 0, math.map(redstone_level, 0, 15, 45, -45))
    local diff = torch_desired_rot.z - torch_rot.z
    torch:rot(math.lerp(torch_rot, torch_desired_rot, 0.5)):uvPixels(redstone_level > 0 and vec(0,-16) or vec(0,0))
    if math.abs(diff) > 1 and redstone_level ~= 0 then
        sounds["minecraft:entity.item_frame.break"]:pos(skull.render_pos):volume(0.5):pitch(0.5 - diff * 0.005 - torch_rot.z * 0.005):play()
    end
    if self.e then
        if song ~= songs[600] then
            song = songs[600]
            self.time = -10
            return
        end
    else
        if redstone_level == 15 then
            return
        elseif redstone_level > 0 then
            if songs[redstone_level] and songs[redstone_level] ~= song then
                song = songs[redstone_level]
                self.setters[skull] = true
                self.time = -10
                return
            end
        end
    end

    if skull.data.stress > 0 then
        skull.data.stress = skull.data.stress * 0.985
        host:setActionbar(skull.data.stress.."")
    end

    if self.time < 0 then
        return
    elseif self.time == 0 and redstone_level ~= 0 then
        sounds["minecraft:entity.fishing_bobber.retrieve"]:pos(skull.render_pos):volume(2):pitch(0.5):play()
        sounds["minecraft:entity.fishing_bobber.retrieve"]:pos(skull.render_pos):volume(2):pitch(0.6):play()
        sounds["minecraft:entity.fishing_bobber.retrieve"]:pos(skull.render_pos):volume(2):pitch(0.7):play()
    end

    local box = skull.renderer.parts[1]
    box:color(math.lerp(vec(1,1,1), vec(1,0,0), math.min((skull.data.stress * 0.08), 1)))
    box:secondaryRenderType(skull.data.stress > 30 and "GLINT2" or "NONE")
    if skull.data.stress > 0.6 then
        particles["smoke"]:pos(skull.render_pos + OFFSET + rng.vec3() * 0.5):velocity(rng.vec3() * 0.05 + vec(0,0.05,0)):scale(0.5):spawn()
    end
    if skull.data.stress > 0.65 then
        particles["smoke"]:pos(skull.render_pos + OFFSET + rng.vec3() * 0.5):velocity(rng.vec3() * 0.15 + vec(0,0.05,0)):scale(0.5):spawn()
        if math.random() > 0.9 then
            particles["flame"]:pos(skull.render_pos + OFFSET + rng.vec3() * 0.5):velocity(rng.vec3() * 0.05 + vec(0,0.05,0)):scale(0.5):spawn()
        end
    end
    if skull.data.stress > 15 then
        for _ = 1, 5 do
            particles["smoke"]:pos(skull.render_pos + OFFSET + rng.vec3() * 0.5):velocity(rng.vec3() * 0.8 + vec(0,0.05,0)):scale(0.5):spawn()
        end
        if math.random() > 0.9 then
            particles["lava"]:pos(skull.render_pos + OFFSET + rng.vec3() * 0.5):velocity(rng.vec3() * 0.05 + vec(0,0.05,0)):scale(0.5):spawn()
        end
    end
    if skull.data.stress > 30 then
        particles["flame"]:pos(skull.render_pos + OFFSET + rng.vec3() * 0.5):velocity(rng.vec3() * 0.5 + vec(0,0.05,0)):scale(0.5):spawn()
        for _ = 1, 5 do
            particles["lava"]:pos(skull.render_pos + OFFSET + rng.vec3() * 0.5):velocity(rng.vec3() * 0.5 + vec(0,0.05,0)):scale(0.8):spawn()
        end
        for _ = 1, 20 do
            particles["smoke"]:pos(skull.render_pos + OFFSET + rng.vec3() * 0.5):velocity(rng.vec3() * 0.8 + vec(0,0.05,0)):scale(0.5):spawn()
        end
    end
    if skull.data.stress > 48 then
        for _ = 1, 10 do
            particles["flame"]:pos(skull.render_pos + OFFSET + rng.vec3() * 0.5):velocity(rng.vec3() * 0.15 + vec(0,rng.float(1,4),0)):scale(1):spawn()
            particles["lava"]:pos(skull.render_pos + OFFSET + rng.vec3() * 0.5):velocity(rng.vec3() * 0.15 + vec(0,rng.float(1,4),0)):scale(0.5):spawn()
        end
        if math.random() > 0.9 then
            sounds["entity.lightning_bolt.thunder"]:pos(skull.pos):volume(0.5):pitch(rng.float(2,4)):play()
        end
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
            skull.data.stress = math.min(skull.data.stress + 0.01, 50)
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

function day:render(skull, delta)
    local box = skull.renderer.parts[1]
    if skull.data.stress > 0.3 then
        local stress = skull.data.stress - 0.3
        box:offsetRot(rng.float(-0.5,0.5) * stress, rng.float(-1.5,1.5) * stress, rng.float(-0.5,0.5) * stress)
    end
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
    if self.e_providers[skull] then
        self.e_providers[skull] = nil
        local count = 0
        for _ in pairs(self.e_providers) do
            count = count + 1
        end
        if count == 0 then
            self.e = false
            song = songs[0]
        end
    end
end
local Skull = require("libraries.Skull")
local SkullRenderer = require("libraries.SkullRenderer")
local calendar = require("libraries.Calendar")
local manager = require("libraries.SkullManager")
local mode_getter = require("libraries.mode_getter")

local function signText(pos)
    local blockstate = world.getBlockState(pos)
    if blockstate.id:find("sign") then
        return parseJson(blockstate:getEntityData().front_text.messages[1]).text
    end
end

local function chooseDay(blockstate)
    return mode_getter.fromBlock(blockstate)
        or calendar:byName(signText(blockstate:getPos() + vec(0, -1, 0)))
        or calendar:today()
        or calendar:getFallback()
end

local rendered = {}
local wearing = {}
function events.SKULL_RENDER(_, blockstate, itemstack, entity, context)
    if next(rendered) then
        for i = #rendered, 1, -1 do
            rendered[i]:visible(false)
            rendered[i] = nil
        end
        rendered = {}
    end

    if blockstate then
        if not manager:get(blockstate:getPos()) then
            manager:add(Skull.new(blockstate, SkullRenderer.new(), chooseDay(blockstate)))
        end
    elseif entity and context == "HEAD" then
        local day = mode_getter.fromItem(itemstack)
        if day then
            day:wornRender(entity)
            for _, part in pairs(day.worn_parts) do
                part:visible(true)
                rendered[#rendered + 1] = part
            end
            wearing[entity:getUUID()] = day
        end
    end
end

local initialized = {}
local initialized_players = {}
function events.WORLD_TICK()
    local active = {}

    for _, skull in next, manager:getAll() do
        local day = skull.day
        active[day] = active[day] or {}
        active[day][#active[day] + 1] = skull
    end
    
    for day, skulls in next, active do
        if not initialized[day] then
            initialized[day] = skulls
            day:globalInit(skulls)
        end
    end
    
    for day, skulls in next, initialized do
        if active[day] then
            day:globalTick(skulls)
        else
            day:globalExit(skulls)
            initialized[day] = nil
        end
    end

    for uuid, day in next, wearing do
        local entity = world.getEntity(uuid)
        if entity then
            if not initialized_players[uuid] then
                initialized_players[uuid] = day
                day:wornInit(entity)
            end
            day:wornTick(entity)
            if entity:getItem(6).id ~= "minecraft:player_head" then
                wearing[uuid] = nil
                initialized_players[uuid] = nil
                day:wornExit(entity)
            end
        else
            wearing[uuid] = nil
            initialized_players[uuid] = nil
        end
    end
end
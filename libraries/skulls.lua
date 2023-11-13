local Skull = require("libraries.Skull")
local SkullRenderer = require("libraries.SkullRenderer")
local Calendar = require("libraries.Calendar")
local base64 = require("libraries.base64")

local skulls = {}

local function signText(pos)
    local blockstate = world.getBlockState(pos)
    if blockstate.id:find("sign") then
        return parseJson(blockstate:getEntityData().front_text.messages[1]).text
    end
end

local function getTextureValue(data)
    local owner = data and data.SkullOwner
    local properties = owner and owner.Properties
    local textures = properties and properties.textures
    return textures and textures[1] and textures[1].Value
end

local function chooseDay(blockstate)
    local texture_value = base64.decode(getTextureValue(blockstate:getEntityData()))
    return texture_value and Calendar:byName(texture_value)
        or Calendar:byName(signText(blockstate:getPos() + vec(0, -1, 0)))
        or Calendar:today()
end

function events.SKULL_RENDER(_, blockstate)
    if blockstate then
        local index = tostring(blockstate:getPos())
        if not skulls[index] then
            skulls[index] = Skull.new(blockstate, SkullRenderer.new(), chooseDay(blockstate))
        end
    end
end

function events.WORLD_TICK()
    for index, skull in next, skulls do
        if world.getBlockState(skull.pos).id ~= "minecraft:air" then
            if not skull.initialized then
                skull:init()
                skull.initialized = true
            end
            if skull.initialized and skull.tick then
                skull:tick(skull)
            end
        else
            skull:remove()
            skulls[index] = nil
        end
    end
end

function events.WORLD_RENDER(delta)
    for _, skull in next, skulls do
        if skull.initialized and skull.render then
            skull:render(delta)
        end
    end
end

event:on("skull_punched", function (pos)
    local index = tostring(pos)
    if skulls[index] then
        skulls[index]:punch()
    end
end)
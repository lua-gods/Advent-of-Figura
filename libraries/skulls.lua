local Skull = require("libraries.Skull")
local SkullRenderer = require("libraries.SkullRenderer")
local Calendar = require("libraries.Calendar")
local base64 = require("libraries.base64")
local manager = require("libraries.SkullManager")

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
        or Calendar:getFallback()
end

function events.SKULL_RENDER(_, blockstate)
    if blockstate then
        if not manager:get(blockstate:getPos()) then
            manager:add(Skull.new(blockstate, SkullRenderer.new(), chooseDay(blockstate)))
        end
    end
end
local Skull = require("libraries.Skull")
local SkullRenderer = require("libraries.SkullRenderer")
local Calendar = require("libraries.Calendar")

local skulls = {}

local function signText(pos)
    local blockstate = world.getBlockState(pos)
    if blockstate.id:find("sign") then
        return tonumber(parseJson(blockstate:getEntityData().front_text.messages[1]).text)
    end
end

function events.SKULL_RENDER(_, blockstate)
    if blockstate then
        local pos = blockstate:getPos()
        local index = tostring(pos)
        if not skulls[index] then
            local day = Calendar:getDay(signText(pos + vec(0, -1, 0))) or Calendar:today()
            skulls[index] = Skull.new(blockstate, SkullRenderer.new(), day)
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
            if skull.tick then
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
        if not skull.init and skull.render then
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
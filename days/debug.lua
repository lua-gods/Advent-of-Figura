local Calendar = require("libraries.Calendar")
local SkullManager = require("libraries.SkullManager")
local day = Calendar:newDay("debug")

local missingno = models.model.days.fallback.cube:setPrimaryTexture("RESOURCE", "missingno")
day:setItemPart(missingno)

local function stats()
    local skulls = {}
    for _, skull in next, SkullManager:getAll() do
        local info = "§7" .. skull.pos.x .. ", " .. skull.pos.y .. ", " .. skull.pos.z .. "§r:§l " .. skull.day.name
        if skull.debugger:hasData() then
            info = info .. " §7(" .. table.concat(skull.debugger:getAll(), ", ") .. ")"
        end
        skulls[#skulls+1] = info
    end
    return ([[
§lDebug Mode
§rInit instructions: §l%s
§rTick instructions: §l%s
§rRender instructions: §l%s
§rComplexity: §l%s
§rParticles: §l%s
§rSounds: §l%s
§rTIME: §l%s
§7---
§rActive Skulls: §l
    ]]..table.concat(skulls, "\n").."\n\n"):format(
        avatar:getInitCount() + avatar:getEntityInitCount(),
        avatar:getTickCount() + avatar:getWorldTickCount(),
        avatar:getRenderCount() + avatar:getWorldRenderCount(),
        avatar:getComplexity(),
        avatar:getMaxParticles() - avatar:getRemainingParticles(),
        avatar:getMaxSounds() - avatar:getRemainingSounds(),
        TIME
    )
end

---@param skull Skull
function day:init(skull)
    local part = skull:addPart(models:newPart("text_anchor"))
    skull.data.task = part:newText("Badge")
    :scale(0.1)
    :pos(0,24,0)
    :alignment("CENTER")
    :shadow(true)
    :background(true)
    :text(stats())
end

function day:render(skull, delta)
    skull.data.task:rot(utils.dirToAngle(((skull.pos + vec(0.5,1.5,0.5)) - client:getCameraPos()):normalize()) + vec(0, skull.rot, 0)):text(stats())
end
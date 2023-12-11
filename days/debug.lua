local Calendar = require("libraries.Calendar")
local SkullManager = require("libraries.SkullManager")
local day = Calendar:newDay("debug")

local missingno = models.model.days.fallback.cube:setPrimaryTexture("RESOURCE", "missingno")
day:setItemPart(missingno)

local function stats()
    return ([[
§lDebug Info
§rInit instructions: §l%s
§rTick instructions: §l%s
§rRender instructions: §l%s
§rComplexity: §l%s
§rParticles: §l%s
§rSounds: §l%s
§rTIME: §l%s
    ]]):format(
        avatar:getInitCount() + avatar:getEntityInitCount(),
        avatar:getTickCount() + avatar:getWorldTickCount(),
        avatar:getRenderCount() + avatar:getWorldRenderCount(),
        avatar:getComplexity(),
        avatar:getMaxParticles() - avatar:getRemainingParticles(),
        avatar:getMaxSounds() - avatar:getRemainingSounds(),
        TIME
    )
end

local function skulls()
    local s = {}
    for _, skull in next, SkullManager:getAll() do
        local info = ":skull: §r" .. skull.pos.x .. " " .. skull.pos.y .. " " .. skull.pos.z .. "§r:§l " .. skull.day.name
        if skull.debugger:hasData() then
            -- info = info .. "\n §7 ├§r " .. table.concat(skull.debugger:getAll(), "\n §7 ├§r ")
            -- replace the final "├" with "└"
            local lines = skull.debugger:getAll()
            local out = ""
            for i = 1, #lines do
                out = out .. "\n§7" .. (i == #lines and "└" or "├") .. "§r " .. lines[i]
            end
            info = info .. out
        end
        s[#s+1] = info
    end
    return "§r§lActive Skulls\n§r" .. table.concat(s, "\n") .. "\n\n"
end

---@param skull Skull
function day:init(skull)
    local part = skull:addPart(models:newPart("text_anchor"))
    skull.data.task = part:newText("Badge")
    :scale(0.1)
    :pos(0,32,0)
    :alignment("RIGHT")
    :shadow(true)
    :background(true)
    :text(stats())
    skull.data.task2 = part:newText("Badge2")
    :scale(0.1)
    :pos(vec(0,32,0))
    :alignment("LEFT")
    :shadow(true)
    :background(true)
    :text(skulls())
    :matrix(matrices.mat4():translate(0,025,200))
end

local function wrapLines(line, before, after)
    return line:gsub("([^\n]+)", (before or "") .. "%1" .. (after or ""))
end

function day:render(skull, delta)
    skull.data.task:rot(utils.dirToAngle(((skull.pos + vec(0.5,1.5,0.5)) - client:getCameraPos()):normalize()) + vec(0, skull.rot, 0)):text(wrapLines(stats(), nil, "§r§7 |"))
    skull.data.task2:rot(utils.dirToAngle(((skull.pos + vec(0.5,1.5,0.5)) - client:getCameraPos()):normalize()) + vec(0, skull.rot, 0)):text(wrapLines(skulls(), "§r§7 "))
end
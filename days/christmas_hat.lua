local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("christmas_hat")


local hatModel = models.christmas_hat.hat

local wornHat = day:addWornPart(hatModel)
wornHat:setScale(0.9, 0.9, 0.9):setPos(0, 6.5, 0)

---runs every time a skull is loaded.
---@param skull Skull
function day:init(skull)
    skull.data.model = skull:addPart(hatModel)
end

---every world tick.
---@param skull Skull
function day:tick(skull)
end

---when the skull is punched.
---@param skull Skull
---@param puncher Player
function day:punch(skull, puncher)
end

---every world render.
---@param skull Skull
---@param delta number
function day:render(skull, delta)

end

---called when the skull is destroyed, unloaded, or switched to a different day. Do cleanup here.
---@param skull Skull
function day:exit(skull)
end

function day:wornRender(entity)

end
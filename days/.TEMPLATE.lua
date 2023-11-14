local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("template", 69)
-- name and day number.

models.model.days.fallback.cube:setPrimaryTexture("RESOURCE", "missingno")
-- do any pre-init stuff here.

--- runs every time a skull is loaded.
---@param skull Skull
function day:init(skull) 
    -- skull.data persists between ticks and is unique to each skull.
    skull.data.flash = particles["flash"]:pos(skull.pos + vec(0.5, 0.5, 0.5)):lifetime(99999):spawn()
    -- skull.pos is the bottom north-west corner of the skull's block.
    
    skull.data.model = skull:addPart(models.model.days.fallback.cube)
    -- adds a ModelPart to the skull, automatically positioning and rotating it.
    -- you can modify the modelpart for each skull via editing the skull.data.model, instead of the model supplied
end
--- every world tick.
---@param skull Skull
function day:tick(skull)
    local rainbow = vectors.hsvToRGB(TIME / 40, 1, 1)
    particles["end_rod"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):velocity(0,1,0):color(rainbow):spawn() -- skull.render_pos accounts for wall head offsets.
end

--- when the skull is punched.
---@param skull Skull
---@param puncher Player
function day:punch(skull, puncher)
    log("ouch")
end

-- every world render.
---@param skull Skull
---@param delta number
function day:render(skull, delta)

end
---called when the skull is destroyed, unloaded, or switched to a different day. Do cleanup here.
---@param skull Skull
function day:exit(skull)
    skull.data.flash:remove()
    -- removes the flash particle we created in init.
end
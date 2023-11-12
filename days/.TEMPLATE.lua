local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("template", 69) -- name and day number.

models.model.days.fallback.cube:setPrimaryTexture("RESOURCE", "missingno") -- do any pre-init stuff here.

function day:init(skull) -- runs every time a skull is loaded.
    skull:addPart(models.model.days.fallback.cube) -- adds a ModelPart to the skull, automatically positioning and rotating it.
    skull.data = { -- skull.data persists between ticks and is unique to each skull.
        flash = particles["flash"]:pos(skull.pos + vec(0.5, 0.5, 0.5)):lifetime(99999):spawn() -- skull.pos is the bottom north-west corner of the skull's block.
    }
end

function day:tick(skull) -- every world tick.
    local rainbow = vectors.hsvToRGB(TIME / 40, 1, 1)
    particles["end_rod"]:pos(skull.pos + vec(0.5, 0.5, 0.5)):velocity(0,1,0):color(rainbow):spawn() -- skull.pos is the bottom north-west corner of the skull's block.
end

function day:punch(skull) -- when the skull is punched.
    log("ouch")
end

function day:render(skull, delta) -- every world render.

end

function day:exit(skull) -- called when the skull is destroyed, unloaded, or switched to a different day. Do cleanup here.
    skull.data.flash:remove() -- we'll remove the flash particle we created in init.
end
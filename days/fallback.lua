local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("fallback")

models.model.days.fallback.cube:setPrimaryTexture("RESOURCE", "missingno")

function day:init(skull)
    skull:addPart(models.model.days.fallback.cube)
end

function day:tick(skull)
    local rainbow = vectors.hsvToRGB(TIME / 40, 1, 1)
    particles["end_rod"]:pos(skull.pos + vec(0.5, 0.5, 0.5)):velocity(0,1,0):color(rainbow):spawn()
end
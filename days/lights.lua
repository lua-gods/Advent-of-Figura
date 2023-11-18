local Calendar = require("libraries.Calendar")
local SplineManager = require("libraries.SplineManager")
local tween = require("libraries.GNTweenLib")

---@class Day.Lights: Day
---@field manager SplineManager
local day = Calendar:newDay("lights")

local manager = SplineManager.new(models.lights.Light:getChildren())

function day:globalTick()
    manager:tick()
end

function day:init(skull)
    manager.needs_pairing = true
    manager:addSkull(skull)
end

function manager.postPartRender(part)
    part:color(vectors.hsvToRGB(rng.float(0,1),1,1)):primaryRenderType("EMISSIVE_SOLID")
end

function manager.postSkullRender(skull)

end

function day:exit(skull)
    manager:exit(skull)
end
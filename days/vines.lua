local Calendar = require("libraries.Calendar")
local SplineManager = require("libraries.SplineManager")

---@class Day.Vines: Day
---@field manager SplineManager
local day = Calendar:newDay("vines")

local item_part = day:setItemPart(models.baubles.Vine.berries)

local manager = SplineManager.new(models.baubles.Vine:getChildren())

function day:globalTick()
    manager:tick()
end

function day:init(skull)
    manager.needs_pairing = true
    manager:addSkull(skull)
    
    math.randomseed(skull.pos.x * 73856093 + skull.pos.y * 19349663 + skull.pos.z * 83492791)
    math.random(); math.random(); math.random()
end

function manager.postSkullRender(skull)

end

function day:exit(skull)
    manager:exit(skull)
end

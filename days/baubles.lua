local Calendar = require("libraries.Calendar")
local SplineManager = require("libraries.SplineManager")
local tween = require("libraries.GNTweenLib")

---@class Day.Baubles: Day
---@field manager SplineManager
local day = Calendar:newDay("baubles")

local worn = day:addWornPart(models.baubles.Bauble.a)

local item_part = day:setItemPart(models.baubles.Bauble.a)
function day:wornRender()
    worn:color(vectors.hsvToRGB((client:getSystemTime() / 5000) % 1,1,1))
end

local baubles = models.baubles.Bauble:getChildren()
local manager = SplineManager.new(models.baubles.Vine:getChildren())

function day:globalTick()
    manager:tick()
    item_part:rot(0, TIME * 0.5, 0):color(vectors.hsvToRGB((client:getSystemTime() / 5000) % 1,0.8,1))
end

function day:init(skull)
    manager.needs_pairing = true
    manager:addSkull(skull)
    
    math.randomseed(skull.pos.x * 73856093 + skull.pos.y * 19349663 + skull.pos.z * 83492791)
    math.random(); math.random(); math.random()
end

function manager.postSkullRender(skull)
    skull:addPart(baubles[math.random(1, #baubles)]):color(vectors.hsvToRGB(rng.float(0,1),1,1))
end

function day:exit(skull)
    manager:exit(skull)
end

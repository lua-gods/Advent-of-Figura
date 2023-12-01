local Calendar = require("libraries.Calendar")
local SplineManager = require("libraries.SplineManager")
local tween = require("libraries.GNTweenLib")

---@class Day.Lights: Day
---@field manager SplineManager
local day = Calendar:newDay("lights")

local manager = SplineManager.new(models.lights.Light:getChildren())
local toggle = false
local colors = {vec(0.8,0,0),vec(0,0.1,0.8),vec(0.95,0.65,0),vec(0,0.6,0.2),}
local colorCount = 0
local isPowered = false
function day:globalTick(skull)
    manager:tick()
    colorCount = 0
    toggle = not toggle
        if TIME % 20 == 0 then
            if isPowered then
                for key,part in pairs(manager.parts) do
                    colorCount = (colorCount + 1 ) % 4
                    part.bulb:setColor(colors[colorCount + 1])
                end
            else
                for key,part in pairs(manager.parts) do
                    toggle = not toggle
                    colorCount = (colorCount + 1 ) % 4
                    if toggle then
                        part.bulb:setColor(colors[colorCount + 1])
                    else
                        part.bulb:setColor(colors[colorCount + 1]/8)
                    end
        
                end
            end
        end
    isPowered = false
end

function day:tick(skull)
    if world.getRedstonePower(skull.pos) ~= 0 then
        isPowered = true
    end
end


function day:init(skull)
    manager.needs_pairing = true
    manager:addSkull(skull)
end

function manager.postPartRender(part)
    colorCount = (colorCount + 1 ) % 4
    part.bulb:setColor(colors[colorCount + 1]):setRot(-part:getRot().x,rng.float(-35,35),0)
    part:primaryRenderType("EMISSIVE_SOLID")
    part.bulb.bulbGlass:setPrimaryRenderType("EMISSIVE"):setOpacity(0.5)
end

function manager.postSkullRender(skull)

end

function day:exit(skull)
    manager:exit(skull)
end
local Calendar = require("libraries.Calendar")
local Swingable3D = require("libraries.Swingable3D")
local deepCopy = require("libraries.deep_copy")

---@class Day.Baubles: Day
---@field manager SplineManager
local day = Calendar:newDay("baubles")

local worn = day:addWornPart(models.baubles.Bauble.a)

local item_part = day:setItemPart(models.baubles.Bauble.a)
function day:wornRender()
    worn:color(vectors.hsvToRGB((client:getSystemTime() / 5000) % 1,1,1))
end

local baubles = models.baubles.Bauble:getChildren()

function day:globalTick()
    item_part:rot(0, TIME * 0.5, 0):color(vectors.hsvToRGB((client:getSystemTime() / 5000) % 1,0.8,1))
end

local function findAnchor(pos)
    for i = 1, 20 do
        if not world.getBlockState(pos + vec(0,i,0)):isAir() then
            return pos + vec(0,i,0)
        end
    end
    return pos + vec(0,1,0)
end

function day:init(skull)
    math.randomseed(skull.pos.x * 73856093 + skull.pos.y * 19349663 + skull.pos.z * 83492791)
    math.random(); math.random(); math.random()

    local part = skull:addPart(models:newPart("bauble_anchor"))

    local anchor = findAnchor(skull.pos)
    local offset = skull.pos - anchor
    part:pos((skull.render_pos - offset) * 16)

    local bauble = deepCopy(baubles[math.random(1, #baubles)]):color(vectors.hsvToRGB(rng.float(0,1),1,1))
    bauble:pos(0,offset.y * 16,0)
    bauble.string:scale(1, -offset.y * 16 - 8, 1)
    part:addChild(bauble)

    local swingable = Swingable3D.new(part)
    skull.data.swingable = swingable
    skull.data.wind = vec(0,0,0)
end

function day:tick(skull)
    if not skull.data.swingable then return end
    skull.data.wind = skull.data.wind * 0.8
    skull.data.swingable:tick(skull.data.wind)
end

function day:punch(skull, puncher)
    skull.data.wind = skull.data.wind - (puncher:getPos() - skull.pos):normalize() * 0.1
end

function day:render(skull, delta)
    if not skull.data.swingable then return end
    skull.data.swingable:render(delta)
end

function day:exit(skull)

end

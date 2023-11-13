local Calendar = require("libraries.Calendar")
local manager = require("libraries.SkullManager")

local day = Calendar:newDay("snowman", 3)

local variants = {
    top = models.snowman.Top:getChildren(),
    middle = models.snowman.Middle:getChildren(),
    bottom = models.snowman.Bottom:getChildren()
}

local function processVariant(model)
    local children = model:getChildren()
    for _, child in next, children do
        processVariant(child)
    end
    local name = model:getName()
    if name:sub(1,1) ~= "$" then return end
    local func = loadstring("return " .. name:sub(2))
    if not func then return end
    pcall(func, model)
end

local function roll(skull)
    skull.renderer:reset()
    local type = "top"
    if world.getBlockState(skull.pos + vec(0,1,0)).id:find("head") then
        type = "bottom"
        if world.getBlockState(skull.pos + vec(0,-1,0)).id:find("head") then
            type = "middle"
        end
    end

    local top_variant = variants[type]
    local bottom_variant = top_variant == variants.middle and variants.bottom or variants.middle

    math.randomseed(skull.pos.x * 73856093 + skull.pos.y * 19349663 + skull.pos.z * 83492791)
    local top = skull:addPart(top_variant[math.random(1, #top_variant)]):rot(0, rng.float(0, 360), 0)
    processVariant(top)

    local below = world.getBlockState(skull.pos + vec(0,-1,0))
    if below:isAir() or below.id:find("head") then
        local bottom = skull:addPart(bottom_variant[math.random(1, #bottom_variant)]):rot(0, rng.float(0, 360), 0)
        processVariant(bottom)
        bottom:setPos(bottom:getPos() - vec(0, 8, 0))
    end
end

function day:init(skull)
    skull.data.ripple = function()
        if skull.data.last_ripple == TIME then return end
        roll(skull)
        skull.data.last_ripple = TIME
        for y = -1, 1, 2 do
            local other_skull = manager:get(skull.pos + vec(0,y,0))
            if other_skull and other_skull.data.ripple then
                other_skull.data.ripple()
            end
        end
    end
    skull.data.ripple()
end

function day:exit(skull)
    skull.data.ripple()
end
local Calendar = require("libraries.Calendar")
local manager = require("libraries.SkullManager")
local tween = require("libraries.GNTweenLib")

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
    local block_above = world.getBlockState(skull.pos + vec(0,1,0))
    local block_below = world.getBlockState(skull.pos + vec(0,-1,0))
    
    local type = "middle"
    if block_above:isAir() then
        type = "top"
    elseif not block_below.id:find("head") then
        type = "bottom"
    end

    local top_variant = variants[type]
    local bottom_variant = not block_below.id:find("head") and variants.bottom or variants.middle

    math.randomseed(skull.pos.x * 73856093 + skull.pos.y * 19349663 + skull.pos.z * 83492791)
    math.random(); math.random(); math.random()
    local top = skull:addPart(top_variant[math.random(1, #top_variant)])
    if type ~= "top" then
        top:rot(0, rng.float(0, 360), 0)
    end
    processVariant(top)
    skull.data.top = top

    local below = world.getBlockState(skull.pos + vec(0,-1,0))
    if below:isAir() or below.id:find("head") then
        local bottom = skull:addPart(bottom_variant[math.random(1, #bottom_variant)]):rot(0, rng.float(0, 360), 0)
        processVariant(bottom)
        bottom:setPos(bottom:getPos() - vec(0, 8, 0))
        skull.data.bottom = bottom
    end
end

local function hint(skull)
    local hint_model = skull:addPart(models.snowman.Bottom.basic)
    hint_model:pos(skull.render_pos * 16 + vec(0, 8.01, 0)):primaryRenderType("TRANSLUCENT")

    tween.tweenFunction(0, 1, 1, "outQuad", function(x)
        hint_model:opacity(x):scale(x * 0.05 + 0.95)
    end, function()
        tween.tweenFunction(1, 0, 1, "outQuad", function(x)
            hint_model:opacity(x):scale(x * 0.05 + 0.95)
        end, function()
            if not hint_model:getParent() then return end
            hint_model:getParent():removeChild(hint_model)
        end)
    end)
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

    local block_above = world.getBlockState(skull.pos + vec(0,1,0))
    local block_below = world.getBlockState(skull.pos + vec(0,-1,0))

    if block_above:isAir() and not block_below.id:find("head") then
        hint(skull)
    end
end

function day:punch(skull, puncher)
    if puncher:getHeldItem().id:find("head") then return end
    local new_rot = skull.data.top:getRot() + vec(0, 360, 0)
    tween.tweenFunction(skull.data.top:getRot(), new_rot, 1, "inOutCubic", function(x)
        skull.data.top:rot(x)
    end)
    if skull.data.bottom then
        local new_rot2 = skull.data.bottom:getRot() - vec(0, 360, 0)
        tween.tweenFunction(skull.data.bottom:getRot(), new_rot2, 1, "inOutCubic", function(x)
            skull.data.bottom:rot(x)
        end)
    end
end

function day:exit(skull)
    skull.data.ripple()
end
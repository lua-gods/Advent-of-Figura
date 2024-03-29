local Calendar = require("libraries.Calendar")
local tween = require("libraries.GNTweenLib")

---@class Day.Snowflakes: Day
local day = Calendar:newDay("snowflakes")

local model = models.snowflakes
local variants = {
    core = model.Core:getChildren(),
    arm1 = model.Arm1:getChildren(),
    arm2 = model.Arm2:getChildren(),
}

local item_part = day:setItemPart(models:newPart("snowflake_item"))
local function randomItem()
    for _, child in pairs(item_part:getChildren()) do
        item_part:removeChild(child)
    end
    item_part:addChild(rng.of(variants.core):copy("core"))
    local variant1 = rng.of(variants.arm1)
    local variant2 = rng.of(variants.arm2)
    for i = 0, 3 do
        item_part:addChild(variant1:copy("arm1_"..i):rot(0, 90 * i, 0))
        item_part:addChild(variant2:copy("arm2_"..i):rot(0, 90 * i, 0))
    end
    item_part:rot(0,45,0):pos(0,4,0)
end

randomItem()

function day:globalTick()
    if TIME % 20 == 0 then
        randomItem()
    end
end

local function tweenIn(part, speed)
    part:scale(0)
    local rot = part:getRot()
    local dir = vec(0, math.floor(TIME + speed) % 2 == 0 and -90 or 90, 0)
    tween.tweenFunction(0, 1, speed, "inOutCirc", function(x)
        part:scale(x--[[@as number]])
        part:rot(rot + dir * x)
    end)
    return part
end

local function tweenOut(part)
    tween.tweenFunction(1, 0, 0.5, "inOutCirc", function(x)
        part:scale(x--[[@as number]])
    end, function()
        part:visible(false)
    end)
end

local palette = {
    vec(0.95, 0.95, 0.95, 1),
    vec(0.87, 0.97, 0.97, 1),
    vec(0.94, 0.97, 0.97, 1),
}

local base_texture = assert(textures.snowflakes)
local texture_variants = {}
for i = 1, 5 do
    local dx, dy = base_texture:getDimensions():unpack()
    local texture = textures:copy("snowflake_"..i, base_texture)
    texture:applyFunc(0, 0, dx, dy, function (col, x, y)
        if col.w == 1 then
            return (rng.of(palette))
        end
    end)
    texture_variants[#texture_variants + 1] = texture
end

---@param skull Skull
---@param seed number
function day:init(skull, seed)
    skull.data.parts = {}
    local formation_speed = rng.float(0.7,1.1)
    skull.data.seed = seed or 1
    local randomseed = skull.pos.x * 56093 + skull.pos.y * 49663 + skull.pos.z * 92791 * (skull.data.seed + skull.rot)
    math.randomseed(randomseed)
    math.random(); math.random(); math.random()

    local root = skull:addPart(models:newPart("snowflakes"))

    local debug_seed = ""

    for _ = 1, rng.int(1, 2) do
        local variant, index = rng.of(variants.core)
        skull.data.parts[#skull.data.parts + 1] = tweenIn(skull:addPart(variant, root):rot(0, rng.step(0, 360, 45), 0), 0.3 * formation_speed)
        debug_seed = debug_seed .. index
    end

    for _ = 1, rng.int(1, 2) do
        local arm, index = rng.of(variants.arm1)
        local step = math.random() > 0.5 and 0 or 45
        for i = 0, 3 do
            skull.data.parts[#skull.data.parts + 1] = tweenIn(skull:addPart(arm, root):rot(0, 90 * i + step, 0), 0.4 * formation_speed)
        end
        debug_seed = debug_seed .. index
    end

    for _ = 1, rng.int(1, 2) do
        local arm, index = rng.of(variants.arm2)
        local step = math.random() > 0.5 and 0 or 45
        for i = 0, 3 do
            skull.data.parts[#skull.data.parts + 1] = tweenIn(skull:addPart(arm, root):rot(0, 90 * i + step, 0), 0.5 * formation_speed)
        end
        debug_seed = debug_seed .. index
    end

    for i = 1, #skull.data.parts do
        local part = skull.data.parts[i]
        part:primaryTexture("CUSTOM", rng.of(texture_variants))
        part:light(15,15)
    end

    local wall = skull.is_wall_head and -90 or 0
    root:rot(wall, wall > 0 and skull.rot or 0, 0):pos(skull.render_pos * 16 + skull.offset * 15):light(15,15)
    skull.data.root = root

    skull.debugger:expose("seed", debug_seed)
end

---@param skull Skull
---@param puncher Player
function day:punch(skull, puncher)
    if puncher:getHeldItem().id:find("head") then return end

    sounds["block.glass.break"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(rng.float(1.5, 2.5)):volume(0.5):subtitle("Snowflake forms"):play()

    for i = 1, #skull.data.parts do
        tweenOut(skull.data.parts[i])
    end

    self:init(skull, skull.data.seed + 1)
end
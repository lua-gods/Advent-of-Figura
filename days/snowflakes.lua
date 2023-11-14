local Calendar = require("libraries.Calendar")
local tween = require("libraries.GNTweenLib")

---@class Day.Snowflakes: Day
local day = Calendar:newDay("snowflakes", 12)

local model = models.snowflakes
local variants = {
    core = model.Core:getChildren(),
    arm1 = model.Arm1:getChildren(),
    arm2 = model.Arm2:getChildren(),
}

local function tweenIn(part, speed)
    part:scale(0)
    tween.tweenFunction(0, 1, speed, "inOutCirc", function(x)
        part:scale(x--[[@as number]])
    end)
    return part
end

local function tweenOut(part)
    tween.tweenFunction(1, 0, 1, "inOutCirc", function(x)
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
local TRANSPARENT_BLACK = vec(0,0,0,0)
local base_texture = assert(textures.snowflakes)
local texture_variants = {}
for i = 1, 5 do
    local dx, dy = base_texture:getDimensions():unpack()
    local texture = textures:copy("snowflake_"..i, base_texture)
    texture:applyFunc(0, 0, dx, dy, function (col, x, y)
        if col.w == 1 then
            return rng.of(palette)
        end
    end)
    texture_variants[#texture_variants + 1] = texture
end

---@param skull Skull
---@param seed number
function day:init(skull, seed)
    skull.data.parts = {}
    local formation_speed = rng.float(0.7,1.1)

    math.randomseed(skull.pos.x * 73856093 + skull.pos.y * 19349663 + skull.pos.z * 83492791 * (seed or 1))
    math.random(); math.random(); math.random()

    for _ = 1, rng.of(1, 2) do
        skull.data.parts[#skull.data.parts + 1] = tweenIn(skull:addPart(rng.of(variants.core)):rot(0, rng.step(0, 360, 45), 0), 0.5 * formation_speed)
    end

    for _ = 1, rng.of(1, 2) do
        local arm = rng.of(variants.arm1)
        local step = math.random() > 0.5 and 0 or 45
        for i = 0, 3 do
            skull.data.parts[#skull.data.parts + 1] = tweenIn(skull:addPart(arm):rot(0, 90 * i + step, 0), 0.75 * formation_speed)
        end
    end

    for _ = 1, rng.of(1, 2) do
        local arm = rng.of(variants.arm2)
        local step = math.random() > 0.5 and 0 or 45
        for i = 0, 3 do
            skull.data.parts[#skull.data.parts + 1] = tweenIn(skull:addPart(arm):rot(0, 90 * i + step, 0), 1 * formation_speed)
        end
    end

    for i = 1, #skull.data.parts do
        local part = skull.data.parts[i]
        part:primaryTexture("CUSTOM", rng.of(texture_variants))
    end
end

---@param skull Skull
function day:tick(skull)

end

---@param skull Skull
function day:punch(skull)
    sounds["block.glass.break"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(rng.float(1.5, 2.5)):volume(0.5):subtitle("Snowflake forms"):play()

    for i = 1, #skull.data.parts do
        tweenOut(skull.data.parts[i])
    end

    self:init(skull, math.random())
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)

end

---@param skull Skull
function day:exit(skull)

end
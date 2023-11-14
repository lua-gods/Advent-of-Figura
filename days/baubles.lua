local Calendar = require("libraries.Calendar")
local manager = require("libraries.SkullManager")
local tween = require("libraries.GNTweenLib")

---@class Day.Baubles: Day
---@field skulls Skull[]
---@field needs_pairing boolean
---@field last_pair integer
local day = Calendar:newDay("baubles", 4)
day.skulls = {}
day.last_pair = 0

local variants = {
    bauble = models.baubles.Bauble:getChildren(),
    vine = models.baubles.Vine:getChildren(),
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

---@param start Vector3
---@param finish Vector3
---@param segment_length number
---@param curvature number
local function catenary(start, finish, segment_length, curvature)
    local function getPoint(t, a, dist, start_point, normal_direction, vertical_offset)
        local x = t * dist - dist / 2
        local y = a * math.cosh(x / a) - a - vertical_offset
        local point = start_point + normal_direction * (x + dist / 2)
        point.y = point.y + y
        return point
    end

    local direction = finish - start
    local dist = direction:length()
    local normal_direction = direction:normalize()
    local a = dist / curvature

    local vertical_offset_start = a * math.cosh(-dist / (2 * a)) - a
    local vertical_offset_end = a * math.cosh(dist / (2 * a)) - a
    local vertical_offset = (vertical_offset_start + vertical_offset_end) / 2

    local points = {}
    local n_segments = math.floor(dist / segment_length)
    for i = -1, n_segments do
        local t = i / n_segments
        local point = getPoint(t, a, dist, start, normal_direction, vertical_offset)
        points[i + 1] = { pos = point }
    end

    return points
end

local function isClear(spline)
    for i = 1, #spline do
        local block = world.getBlockState(spline[i].pos)
        if not (block:isAir() or block.id:find("head")) then
            return false
        end
    end
    return true
end

local function dirToAngle(dir)
    return vec(-math.deg(math.asin(dir.y)), math.deg(math.atan2(dir.x, dir.z)), 0)
end

local function renderSpline(skull, spline)
    if isClear(spline) then
        for i = 1, #spline do
            local point = spline[i]
            local offset = math.lerp(skull.data.last.offset, skull.offset, i / #spline)
            local vine = skull:addPart(variants.vine[math.random(1, #variants.vine)], (point.pos + offset), dirToAngle((point.pos - spline[i - 1].pos):normalize()))
            processVariant(vine)
        end
    end
end

local function roll(skull)
    skull.renderer:reset()

    math.randomseed(skull.pos.x * 73856093 + skull.pos.y * 19349663 + skull.pos.z * 83492791)
    math.random(); math.random(); math.random()

    local bauble = skull:addPart(variants.bauble[math.random(1, #variants.bauble)])
    processVariant(bauble)

    if skull.data.last then
        local i = 0
        local spline
        repeat
            spline = catenary(skull.data.last.pos, skull.pos, 0.4, 1.5 - i * 0.1)
            i = i + 1
        until isClear(spline) or i > 10
        renderSpline(skull, spline)
    end
end

local function shuffle(tbl)
    table.sort(tbl, function (a, b)
        return a.pos:lengthSquared() > b.pos:lengthSquared()
    end)
end

function day:pairSkulls()
    shuffle(self.skulls)
    local connected = {}
    for i = 1, #self.skulls do
        local skull = self.skulls[i]
        local other_skull
        local j = 0
        repeat
            j = j + 1
            other_skull = self.skulls[math.random(1, #self.skulls)]
        until (not connected[other_skull] and skull ~= other_skull) or j > 10
        connected[other_skull] = true
        skull.data.last = other_skull
        roll(skull)
    end
end

function day:addSkull(skull)
    self.skulls[#self.skulls + 1] = skull
    self.needs_pairing = true
end

function day:init(skull)
    self:addSkull(skull)
end

function day:tick(skull)
    if self.needs_pairing and TIME > self.last_pair then
        self:pairSkulls()
        self.last_pair = TIME
        self.needs_pairing = false
    end
    -- if skull.data.last then
    --     local diff = (skull.data.last.render_pos + vec(0.5,0.5,0.5)) - (skull.render_pos + vec(0.5,0.5,0.5))
    --     local dir = diff:copy():normalize()
    --     local max = diff:length()
    --     for i = 0, max, 8 do
    --         local point = skull.render_pos + vec(0.5,0.5,0.5) + dir * math.min(max, i + (TIME / 4) % 8)
    --         particles["end_rod"]:pos(point):gravity():scale(0.5):lifetime(10):spawn()
    --     end
    -- end
end

function day:punch(skull, puncher)
    if puncher:getHeldItem().id:find("head") then return end
end

function day:exit(skull)
    for i = 1, #self.skulls do
        if self.skulls[i] == skull then
            table.remove(self.skulls, i)
            break
        end
    end
    self.needs_pairing = true
end
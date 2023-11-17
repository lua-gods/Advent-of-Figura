---@class SplineManager
---@field variants ModelPart[]
---@field last_pair number
---@field skulls Skull[]
---@field postRender fun(skull: Skull)
local SplineManager = {}
SplineManager.__index = SplineManager

function SplineManager.new(variants)
    local self = setmetatable({}, SplineManager)
    self.variants = variants
    self.last_pair = 0
    self.skulls = {}
    return self
end

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

function SplineManager:renderSpline(skull, spline, connected)
    if isClear(spline) then
        for j = 1, #spline do
            local point = spline[j]
            local offset = math.lerp(connected.offset, skull.offset, j / #spline)
            local vine = skull:addPart(self.variants[math.random(1, #self.variants)]):pos((point.pos + offset) * 16):rot(dirToAngle((point.pos - spline[j - 1].pos):normalize()))
            processVariant(vine)
        end
    end
end

function SplineManager:roll(skull)
    skull.renderer:reset()
    if skull.data.to_connect then
        for i = 1, #skull.data.to_connect do
            local other = skull.data.to_connect[i]
            if not other.data.connected[skull] then
                local j = 0
                local spline
                repeat
                    spline = catenary(other.pos, skull.pos, 0.4, 1.5 - j * 0.1)
                    j = j + 1
                until isClear(spline) or j > 10
                self:renderSpline(skull, spline, other)
                skull.data.connected[other] = true
            end
        end
    end
    self.postRender(skull)
end

function SplineManager:pairSkulls()
    for i = 1, #self.skulls do
        local skull = self.skulls[i]
        local first_closest, second_closest
        local first_closest_dist, second_closest_dist = math.huge, math.huge
        for j = 1, #self.skulls do
            if i ~= j then
                local other = self.skulls[j]
                local dist = (skull.pos - other.pos):lengthSquared()
                if dist < first_closest_dist then
                    second_closest = first_closest
                    second_closest_dist = first_closest_dist
                    first_closest = other
                    first_closest_dist = dist
                elseif dist < second_closest_dist then
                    second_closest = other
                    second_closest_dist = dist
                end
            end
        end
        skull.data.to_connect = {
            first_closest,
            second_closest,
        }
        skull.data.connected = {}
    end

    for i = 1, #self.skulls do
        self:roll(self.skulls[i])
    end
end

function SplineManager:addSkull(skull)
    self.skulls[#self.skulls + 1] = skull
end

function SplineManager:tick()
    if self.needs_pairing and TIME > self.last_pair then
        self:pairSkulls()
        self.last_pair = TIME
        self.needs_pairing = false
    end
end

function SplineManager:exit(skull)
    for i = 1, #self.skulls do
        if self.skulls[i] == skull then
            table.remove(self.skulls, i)
            break
        end
    end
    self.needs_pairing = true
end

return SplineManager
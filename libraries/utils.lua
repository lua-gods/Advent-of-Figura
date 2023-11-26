---@diagnostic disable: missing-parameter
local EPSILON = 2.2204460492503131e-16

local deg = math.deg
local atan2 = math.atan2
local sqrt = math.sqrt
local max = math.max
local min = math.min
local abs = math.abs

local dot = vec(0,0,0).dot

local utils = {}

---@param dir Vector3
---@return Vector3 angle
function utils.dirToAngle(dir)
    return vec(-deg(atan2(dir.y, sqrt(dir.x * dir.x + dir.z * dir.z))), deg(atan2(dir.x, dir.z)), 0)
end

---@param model ModelPart
---@return ModelPart
function utils.deepCopy(model)
    local copy = model:copy(model:getName())
    for _, child in pairs(copy:getChildren()) do
        copy:removeChild(child):addChild(utils.deepCopy(child)):parentType()
    end
    return copy
end

---@param ray_pos Vector3
---@param ray_dir Vector3
---@param box_pos Vector3
---@param box_min Vector3
---@param box_max Vector3
---@return boolean intersected, Vector3? intersection_point
function utils.intersectBox(ray_pos, ray_dir, box_pos, box_min, box_max)
    local x1, y1, z1 = (box_pos:copy():add(box_min):sub(ray_pos)):div(ray_dir):unpack()
    local x2, y2, z2 = (box_pos:copy():add(box_max):sub(ray_pos)):div(ray_dir):unpack()
    local tmin = max(min(x1, x2), min(y1, y2), min(z1, z2))
    local tmax = min(max(x1, x2), max(y1, y2), max(z1, z2))
    if tmax < 0 or tmin > tmax then return false end
    return true, ray_pos:copy():add(ray_dir:copy():mul(tmin))
end

---@param ray_pos Vector3
---@param ray_dir Vector3
---@param plane_pos Vector3
---@param plane_normal Vector3
---@return boolean intersected, Vector3? intersection_point
function utils.intersectPlane(ray_pos, ray_dir, plane_pos, plane_normal)
    local denom = dot(plane_normal, ray_dir)
    if abs(denom) < EPSILON then return false end
    local d = plane_pos - ray_pos
    local t = dot(d, plane_normal) / denom
    if t < EPSILON then return false end
    return true, ray_pos + ray_dir * t
end

---@param a Vector3
---@param b Vector3
---@return fun():number?,number?,number?
function utils.area(a, b)
    local lx, ux = min(a.x, b.x), max(a.x, b.x)
    local ly, uy = min(a.y, b.y), max(a.y, b.y)
    local lz, uz = min(a.z, b.z), max(a.z, b.z)
    local x, y, z = lx, ly, lz
    return function()
        if x > ux then return nil end
        local cx, cy, cz = x, y, z
        if z < uz then
            z = z + 1
        elseif y < uy then
            y, z = y + 1, lz
        else
            x, y, z = x + 1, ly, lz
        end
        return cx, cy, cz
    end
end

---@type table<string, number>
local cooldowns = {}
---@param key string
---@param next_time integer
---@return boolean ready
function utils.cooldown(key, next_time)
    if not cooldowns[key] or cooldowns[key] < TIME then
        cooldowns[key] = TIME + next_time
        return true
    end
    return false
end

_G.utils = utils
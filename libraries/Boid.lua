local MAX_NEIGHBOURS = 20

---@class Boid
---@field pos Vector3
---@field vel Vector3
---@field acc Vector3
---@field dir Vector3
---@field _pos Vector3
---@field _dir Vector3
local Boid = {}
Boid.__index = Boid

function Boid.new()
    local self = setmetatable({}, Boid)
    self.pos = vec(0,0,0)
    self._pos = vec(0,0,0)
    self.vel = vec(0,0,0)
    self.acc = vec(0,0,0)
    self.dir = vec(0,0,0)
    self._dir = vec(0,0,0)
    return self
end

---@param neighbours Boid[]
---@param desired_separation number
function Boid:separate(neighbours, desired_separation)
    local steer = vec(0, 0, 0)
    local count = 0
    local sep_so = desired_separation ^ 2
    for i = 1, #neighbours do
        if count >= MAX_NEIGHBOURS then break end
        local other = neighbours[i]
        local offset = self.pos - other.pos
        local d_sq = offset:lengthSquared()
        if d_sq > 0 and d_sq < sep_so then
            local diff = offset:copy()
            local dist = d_sq ^ 0.5
            diff = diff / dist
            steer = steer + diff
            count = count + 1
        end
    end
    if count > 0 then
        steer = steer / count
    end
    return steer
end

---@param neighbours Boid[]
---@param neighbor_dist number
function Boid:align(neighbours, neighbor_dist)
    local sum = vec(0, 0, 0)
    local count = 0
    for i = 1, #neighbours do
        if count >= MAX_NEIGHBOURS then break end
        local other = neighbours[i]
        local d = (self.pos - other.pos):length()
        if d > 0 and d < neighbor_dist then
            sum = sum + other.vel
            count = count + 1
        end
    end
    if count > 0 then
        sum = sum / count
        sum:normalize()
        return sum
    else
        return vec(0, 0, 0)
    end
end

---@param neighbours Boid[]
---@param neighbor_dist number
function Boid:cohere(neighbours, neighbor_dist)
    local sum = vec(0, 0, 0)
    local count = 0
    local sq_max = neighbor_dist ^ 2
    for i = 1, #neighbours do
        if count >= MAX_NEIGHBOURS then break end
        local other = neighbours[i]
        local d = (self.pos - other.pos):lengthSquared()
        if d > 0 and d < sq_max then
            sum = sum + other.pos
            count = count + 1
        end
    end
    if count > 0 then
        sum = sum / count
        return (sum - self.pos):normalize()
    else
        return vec(0, 0, 0)
    end
end

local RAYCAST_MAX = 10
---@param pos Vector3
---@param dir Vector3
---@return Vector3?
local function cast(pos, dir)
    local ray_dir = dir:copy():normalize()
    for i = 0, RAYCAST_MAX, 0.25 do
        local ray_pos = pos + ray_dir * i
        if world.getBlockState(ray_pos):hasCollision() then
            return ray_pos
        end
    end
    return pos
end

local RAYS = 1
function Boid:avoid()
    local avoid = vec(0,0,0)
    for i = 1, RAYS do
        local hit = cast(self.pos, self.vel + rng.vec3() * 0.5)
        avoid = avoid + (self.pos - hit):normalize()
    end
    return avoid / RAYS
end

---@param target Vector3
function Boid:seek(target, when_over)
    if not target then
        return vec(0,0,0)
    end
    local desired = (target - self.pos)
    if desired:lengthSquared() < when_over ^ 2 then
        return vec(0,0,0)
    end
    desired = desired * 0.1
    local steer = (desired - self.vel)
    return steer
end

local separation_scalar = 1.5
local alignment_scalar = 1.0
local cohesion_scalar = 1.5
local seek_scalar = 0.5
local avoid_scalar = 1.5

---@param target Vector3
function Boid:applyForces(neighbours, target)
    local separation_force = self:separate(neighbours, 1.5)
    local alignment_force = self:align(neighbours, 2)
    local cohesion_force = self:cohere(neighbours, 1.5)
    local seek_force = self:seek(target, 8)
    local avoid_force = self:avoid()

    self.acc = self.acc + self.dir * 0.5
    self.acc = self.acc + vec(0,0.1,0)
    self.acc = self.acc + (separation_force * separation_scalar)
    self.acc = self.acc + (alignment_force * alignment_scalar)
    self.acc = self.acc + (cohesion_force * cohesion_scalar)
    self.acc = self.acc + (seek_force * seek_scalar)
    self.acc = self.acc + (avoid_force * avoid_scalar)
end

---@param target Vector3
function Boid:tick(neighbours, target)
    self:applyForces(neighbours, target)
    self._pos = self.pos
    self._dir = self.dir
    self.pos = self.pos + self.vel
    self.acc = self.acc * 0.01
    self.vel = self.vel + self.acc
    self.acc = vec(0,0,0)
    self.dir = math.lerp(self.dir, self.vel, 0.2) --[[@as Vector3]]
end

---@param delta number
function Boid:getPos(delta)
    return math.lerp(self._pos, self.pos, delta)
end

---@param delta number
function Boid:getRot(delta)
    local dir = math.lerp(self._dir, self.dir, delta):normalize() --[[@as Vector3]]
    local rot = utils.dirToAngle(dir)
    return vec(-rot.x, rot.y + 180, 0)
end

return Boid
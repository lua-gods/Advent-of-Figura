---@class Boid
---@field pos Vector3
---@field vel Vector3
---@field acc Vector3
---@field dir Vector3
---@field _pos Vector3
---@field _dir Vector3
---@field ticker fun(toggle: boolean)
local Boid = {
    pos = vec(0,0,0),
    _pos = vec(0,0,0),
    vel = vec(0,0,0),
    acc = vec(0,0,0),
    dir = vec(0,0,0),
    _dir = vec(0,0,0),
}
Boid.__index = Boid

local boids = {}
function Boid.new()
    local self = setmetatable({}, Boid)
    boids[#boids+1] = self
    return self
end

---@param desired_separation number
function Boid:separate(desired_separation)
    local steer = vec(0, 0, 0)
    local count = 0
    local sep_so = desired_separation ^ 2
    for i = 1, #boids do
        local other = boids[i]
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

---@param neighbor_dist number
function Boid:align(neighbor_dist)
    local sum = vec(0, 0, 0)
    local count = 0
    for i = 1, #boids do
        local other = boids[i]
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

---@param neighbor_dist number
function Boid:cohere(neighbor_dist)
    local sum = vec(0, 0, 0)
    local count = 0
    for i = 1, #boids do
        local other = boids[i]
        local d = (self.pos - other.pos):length()
        if d > 0 and d < neighbor_dist then
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

---@param pos Vector3
---@param dir Vector3
---@return Vector3?
local function cast(pos, dir)
    for i = 0, 10, 0.5 do
        local ray_pos = pos + dir * i
        if not world.getBlockState(pos + dir * i):isAir() then
            return ray_pos
        end
    end
end

function Boid:avoid(dist)
    local hit = cast(self.pos, self.dir)
    if not hit then
        return vec(0,0,0)
    end
    return (self.pos - hit):normalize()
end

---@param target Vector3
function Boid:seek(target)
    local desired = (target - self.pos)
    desired = desired * 0.1
    local steer = (desired - self.vel)
    return steer
end

local separation_scalar = 1.5
local alignment_scalar = 1.0
local cohesion_scalar = 1.0
local seek_scalar = 1.0
local avoid_scalar = 8.0

---@param target Vector3
function Boid:applyForces(target)
    local separation_force = self:separate(1.5)
    local alignment_force = self:align(1)
    local cohesion_force = self:cohere(2)
    local seek_force = self:seek(target)
    local avoid_force = self:avoid(20)

    self.acc = self.acc + (separation_force * separation_scalar)
    self.acc = self.acc + (alignment_force * alignment_scalar)
    self.acc = self.acc + (cohesion_force * cohesion_scalar)
    self.acc = self.acc + (seek_force * seek_scalar)
    self.acc = self.acc + (avoid_force * avoid_scalar)
end

---@param target Vector3
function Boid:tick(target)
    self:applyForces(target)
    self._pos = self.pos
    self._dir = self.dir
    self.pos = self.pos + self.vel
    self.acc = self.acc * 0.01
    self.vel = self.vel + self.acc
    self.acc = vec(0,0,0)
    self.dir = self.vel
end

---@param delta number
function Boid:getPos(delta)
    return math.lerp(self._pos, self.pos, delta)
end

-- ---@param delta number
-- function Boid:getRot(delta)
--     local dir = math.lerp(self._dir, self.dir, delta):normalize() --[[@as Vector3]]
--     return utils.dirToAngle(dir)
-- end

function Boid:remove()
    for i = 1, #boids do
        if boids[i] == self then
            table.remove(boids, i)
            break
        end
    end
end

return Boid
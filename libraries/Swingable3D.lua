local AIR_RESISTANCE = 0.15
local GRAVITY = -9.81
local SIM_SPEED = 5

---@class Swingable3D
---@field part ModelPart
---@field base Vector3
---@field pos Vector3
---@field _pos Vector3
---@field rot Vector3
---@field _rot Vector3
---@field equilibrium Vector3
---@field spring number
---@field offset number
---@field velocity Vector3
---@field last_sound number
local Swingable3D = {}
Swingable3D.__index = Swingable3D

---@param part ModelPart
---@return Swingable3D
function Swingable3D.new(part, pos)
    local self = setmetatable({}, Swingable3D)
    self.part = part
    self.base = pos:copy()
    self.pos = pos:copy()
    self._pos = self.pos:copy()
    self.rot = vec(0,0,0)
    self.equilibrium = vec(0,1,0)
    self.velocity = vec(0,0,0)
    self.spring = 0
    self.offset = 0
    self.last_sound = TIME
    return self
end

local function reflect(velocity, normal)
    return velocity - 2 * velocity:dot(normal) * normal
end

local function drawBounds(min, max, lifetime)
    local size = max - min
    particles["end_rod"]:lifetime(lifetime):gravity():scale(0.2):pos(min + vec(0,0,0)):spawn()
    particles["end_rod"]:lifetime(lifetime):gravity():scale(0.2):pos(min + vec(0,0,size.z)):spawn()
    particles["end_rod"]:lifetime(lifetime):gravity():scale(0.2):pos(min + vec(0,size.y,0)):spawn()
    particles["end_rod"]:lifetime(lifetime):gravity():scale(0.2):pos(min + vec(0,size.y,size.z)):spawn()
    particles["end_rod"]:lifetime(lifetime):gravity():scale(0.2):pos(min + vec(size.x,0,0)):spawn()
    particles["end_rod"]:lifetime(lifetime):gravity():scale(0.2):pos(min + vec(size.x,0,size.z)):spawn()
    particles["end_rod"]:lifetime(lifetime):gravity():scale(0.2):pos(min + vec(size.x,size.y,0)):spawn()
    particles["end_rod"]:lifetime(lifetime):gravity():scale(0.2):pos(min + vec(size.x,size.y,size.z)):spawn()
end

function Swingable3D:impactSound(play_bulk)
    if (TIME - self.last_sound > 1) then
        sounds["block.amethyst_block.place"]:pos(self:getPos()):pitch(rng.float(2.5,4)):play()
        self.last_sound = TIME
    elseif play_bulk then
        sounds["impact" .. rng.int(1,6)]:pos(self:getPos()):play()
        self.last_sound = TIME
    end
end

function Swingable3D:tick(other_swingables)
    local min, max = self:getBounds()
    drawBounds(min, max, 1)

    local dt = 0.05

    local velocity = ((self.pos - self._pos) + self.velocity) / dt

    self.velocity = self.velocity * 0.8

    local air_resistance = velocity * (-AIR_RESISTANCE)
    velocity = velocity + air_resistance * dt

    local spring_force = self.equilibrium:normalized() * (-self.spring)
    velocity = velocity + spring_force * dt

    velocity = velocity + vec(0, GRAVITY * ((dt * 1.3 * SIM_SPEED)^2), 0)

    local colliding, normal = self:isColliding(other_swingables)
    if colliding then
        local reflect_dir = reflect(velocity, normal)
        local damping = 0.8
        local vel = -reflect_dir * damping

        self:impactSound(true)

        self._pos = self.pos:copy()
        self.pos = self.pos + vel * dt
    else
        self._pos = self.pos:copy()
        self.pos = self.pos + velocity * dt
    end

    local direction = self.pos - self.base
    self.pos = self.base + direction:normalized()

    local relative = self.pos - self.base
    relative = vectors.rotateAroundAxis(90, relative, vec(-1, 0, 0))
    local yaw = math.deg(math.atan2(relative.x, relative.z))
    local pitch = math.deg(math.asin(-relative.y))

    self._rot = self.rot:copy()
    self.rot = vec(pitch, 0, yaw)
end

function Swingable3D:getPos()
    local dir = self.pos - self.base
    local pos = self.base + dir:normalized() * -self.offset + vec(0, 0.25, 0)
    return pos
end

function Swingable3D:getBounds()
    local pos = self:getPos()
    local size = 0.5
    local half = size / 2
    local min = pos - vec(half, half, half)
    local max = pos + vec(half, half, half)
    return min, max
end

function Swingable3D:isColliding(other_swingables)
    local min, max = self:getBounds()
    local search_min = min:copy():floor()
    local search_max = max:copy():floor()
    local collision_normal = vec(0, 0, 0)
    local max_penetration_depth = 0

    for x = search_min.x, search_max.x do
        for y = search_min.y, search_max.y do
            for z = search_min.z, search_max.z do
                local block_pos = vec(x, y, z)
                local block = world.getBlockState(block_pos)
                if not block.id:find("head") then
                    local boxes = block:getCollisionShape()
                    for i = 1, #boxes do
                        local box = boxes[i]
                        local box_min = box[1] + block_pos
                        local box_max = box[2] + block_pos
                        drawBounds(box_min, box_max, 10)
                        if not (box_max.x <= min.x or max.x <= box_min.x or
                                box_max.y <= min.y or max.y <= box_min.y or
                                box_max.z <= min.z or max.z <= box_min.z) then
                            local penetration_depth_x = math.min(max.x - box_min.x, box_max.x - min.x)
                            local penetration_depth_y = math.min(max.y - box_min.y, box_max.y - min.y)
                            local penetration_depth_z = math.min(max.z - box_min.z, box_max.z - min.z)

                            if penetration_depth_x > max_penetration_depth then
                                max_penetration_depth = penetration_depth_x
                                collision_normal = vec(1, 0, 0)
                            end
                            if penetration_depth_y > max_penetration_depth then
                                max_penetration_depth = penetration_depth_y
                                collision_normal = vec(0, 1, 0)
                            end
                            if penetration_depth_z > max_penetration_depth then
                                max_penetration_depth = penetration_depth_z
                                collision_normal = vec(0, 0, 1)
                            end
                        end
                    end
                end
            end
        end
    end

    for i = 1, #other_swingables do
        local collider = other_swingables[i]
        if collider ~= self then
            local their_min, their_max = collider:getBounds()
            if not (their_max.x <= min.x or max.x <= their_min.x or
                    their_max.y <= min.y or max.y <= their_min.y or
                    their_max.z <= min.z or max.z <= their_min.z) then
                local collision_dir = (self:getPos() - collider:getPos()):normalized()
                self.velocity = collision_dir * 0.005
                self.pos = self.pos + collision_dir * 0.01
                self:impactSound()
            end
        end
    end

    if max_penetration_depth > 0 then
        return true, collision_normal
    else
        return false
    end
end

function Swingable3D:render(delta)
    self.part:setRot(math.lerp(self._rot, self.rot, delta))
end

function Swingable3D:remove()
    self.part:getParent():removeChild(self.part)
end

return Swingable3D

local AIR_RESISTANCE = 0.15
local GRAVITY = -9.81
local SIM_SPEED = 5

---@class Swingable3D
---@field part ModelPart
---@field pos Vector3
---@field _pos Vector3
---@field rot Vector3
---@field _rot Vector3
---@field equilibrium Vector3
---@field spring number
local Swingable3D = {}
Swingable3D.__index = Swingable3D

---@param part ModelPart
---@return Swingable3D
function Swingable3D.new(part)
    local self = setmetatable({}, Swingable3D)
    self.part = part
    self.pos = part:partToWorldMatrix():apply()
    self._pos = self.pos:copy()
    self.rot = vec(0,0,0)
    self.equilibrium = vec(0,1,0)
    self.spring = 0
    return self
end

---@param input_velocity Vector3
function Swingable3D:tick(input_velocity)
    local dt = 0.05

    local base = self.part:partToWorldMatrix():apply()
    local velocity = ((self.pos - self._pos) + (input_velocity or vec(0,0,0))) / dt

    local air_resistance = velocity * (-AIR_RESISTANCE)
    velocity = velocity + air_resistance * dt

    local spring_force = self.equilibrium:normalized() * (-self.spring)
    velocity = velocity + spring_force * dt

    velocity = velocity + vec(0, GRAVITY * ((dt * 1.3 * SIM_SPEED)^2), 0)

    self._pos = self.pos:copy()
    self.pos = self.pos + velocity * dt

    local direction = self.pos - base
    self.pos = base + direction:normalized()

    local relative = self.part:partToWorldMatrix():invert():apply(base + (self.pos - base)):normalize()
    relative = vectors.rotateAroundAxis(90, relative, vec(-1, 0, 0))
    local yaw = math.deg(math.atan2(relative.x, relative.z))
    local pitch = math.deg(math.asin(-relative.y))

    self._rot = self.rot:copy()
    self.rot = vec(pitch, 0, yaw)
end

function Swingable3D:render(delta)
    self.part:setRot(math.lerp(self._rot, self.rot, delta))
end

function Swingable3D:remove()
    self.part:getParent():removeChild(self.part)
end

return Swingable3D

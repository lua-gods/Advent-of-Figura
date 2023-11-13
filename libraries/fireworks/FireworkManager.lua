local Firework = require("libraries.fireworks.Firework")

---@class FireworkManager
---@field private fireworks Firework[]
local FireworkManager = {}
FireworkManager.__index = FireworkManager

function FireworkManager.new()
    local self = setmetatable({}, FireworkManager)
    self.fireworks = {}
    return self
end

function FireworkManager:spawn(pos, vel, blast)
    self:add(Firework.new(pos, vel, blast))
end

---@param firework Firework
function FireworkManager:add(firework)
    self.fireworks[#self.fireworks+1] = firework
end

function FireworkManager:tick()
    for i = #self.fireworks, 1, -1 do
        local firework = self.fireworks[i]
        firework:tick()
        if firework:isDead() then
            table.remove(self.fireworks, i)
        end
    end
end

function FireworkManager:remove()
    self.fireworks = {}
end

return FireworkManager
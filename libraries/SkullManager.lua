---@class SkullManager
---@field skulls table<string, Skull>
local SkullManager = {}
SkullManager.__index = SkullManager

function SkullManager.new()
    local self = setmetatable({}, SkullManager)
    self.skulls = {}
    self:init()
    return self
end

---@param skull Skull
function SkullManager:add(skull)
    self.skulls[tostring(skull.pos)] = skull
end

---@param pos Vector3
---@return Skull
function SkullManager:get(pos)
    return self.skulls[tostring(pos:copy():floor())]
end

---@param pos Vector3
---@return boolean
function SkullManager:has(pos)
    return self:get(pos) ~= nil
end

---@param skull Skull
function SkullManager:remove(skull)
    skull:remove()
    self.skulls[tostring(skull.pos)] = nil
end

---@param pos Vector3
function SkullManager:removeAt(pos)
    local index = tostring(pos)
    if self.skulls[index] then
        self.skulls[index]:remove()
        self.skulls[index] = nil
    end
end

function SkullManager:init()
    function events.WORLD_TICK()
        for _, skull in next, self.skulls do
            if world.getBlockState(skull.pos).id ~= "minecraft:air" then
                if not skull.initialized then
                    skull:init()
                    skull.initialized = true
                end
                if skull.initialized and skull.tick then
                    skull:tick()
                end
            else
                self:remove(skull)
            end
        end
    end

    function events.WORLD_RENDER(delta)
        for _, skull in next, self.skulls do
            if skull.initialized and skull.render then
                skull:render(delta)
            end
        end
    end

    event:on("skull_punched", function (pos, puncher)
        local skull = self:get(pos)
        if skull then
            skull:punch(puncher)
        end
    end)
end

return SkullManager.new()
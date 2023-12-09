local bubbles = {}
local Bubble = {}
Bubble.__index = Bubble

local id = 0
function Bubble.new(pos, dir)
    local self = setmetatable({}, Bubble)
    self.id = id; id = id + 1
    self.direction = dir
    self.lifetime = rng.int(120,240)
    self.particle = particles["bubble"]:pos(pos):lifetime(self.lifetime):color(vectors.hsvToRGB(rng.float(0.5,0.9),0.5,1)):scale(rng.float(0.1,0.7))
    sounds["block.bubble_column.upwards_ambient"]:pos(pos):subtitle("Bubbles spawn"):volume(0.05):pitch(rng.float(1.2,1.4)):play()
    bubbles[self.id] = self
    return self
end

function Bubble:tick()
    self.direction = math.lerp(self.direction, rng.vec3() * 0.3, 0.05)
    self.particle:velocity(self.direction):spawn()
end

function Bubble:collide(boxes)
    for i = 1, #boxes do
        local box = boxes[i]
        local min = box.min
        local max = box.max
        local pos = self.particle:getPos()
        if pos.x >= min.x and pos.x <= max.x and pos.y >= min.y and pos.y <= max.y and pos.z >= min.z and pos.z <= max.z then
            self:pop()
            return
        end
    end
end

function Bubble:pop()
    particles["bubble_pop"]:pos(self.particle:getPos()):scale(self.particle:getScale()):spawn()
    for i = 1, 8 do
        particles["rain"]:pos(self.particle:getPos()):scale(self.particle:getScale()):spawn()
    end
    sounds["block.bubble_column.bubble_pop"]:pos(self.particle:getPos()):volume(0.1):pitch(self.particle:getScale()*2):subtitle("Bubbles pop"):play()
    bubbles[self.id] = nil
end

function events.TICK()
    local boxes = {}
    for _, player in pairs(world.getPlayers()) do
        local hitbox = player:getBoundingBox()
        local min = player:getPos():add(vec(-hitbox.x/2, 0, -hitbox.z/2))
        local max = player:getPos():add(vec(hitbox.x/2, hitbox.y, hitbox.z/2))
        boxes[#boxes+1] = { min = min, max = max }

        if player:isSwingingArm() then
            local look_dir = player:getLookDir()
            local pos = player:getPos():add(vec(0,player:getEyeHeight(),0))
            for i = 1, 8, 0.4 do
                local raycast_pos = pos + look_dir * i
                boxes[#boxes+1] = { min = raycast_pos - vec(0.3,0.3,0.3), max = raycast_pos + vec(0.3,0.3,0.3) }
            end
        end

        local target = player:getTargetedEntity()
        if target then
            local target_box = target:getBoundingBox()
            local target_min = target:getPos():add(vec(-target_box.x/2, 0, -target_box.z/2))
            local target_max = target:getPos():add(vec(target_box.x/2, target_box.y, target_box.z/2))
            boxes[#boxes+1] = { min = target_min, max = target_max }
        end
    end

    for _, bubble in pairs(bubbles) do
        bubble:tick()
        bubble:collide(boxes)
        bubble.lifetime = bubble.lifetime - 1
        if bubble.lifetime <= 0 then
            bubble:pop()
        end
    end
end

return Bubble
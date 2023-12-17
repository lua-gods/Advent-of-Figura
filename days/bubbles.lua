local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("bubbles")
local Bubble = require("libraries.Bubble")

---@param skull Skull
function day:init(skull)
    skull.data.overdrive = 0
    skull.data.part = skull:addPart(models.bubbles.Machine)
end

---@param skull Skull
function day:tick(skull)
    local pos = skull.pos + vec(0.5,0.5,0.5) + vec(0,0.3,0) + vec(math.sin((TIME + 2)/10),0,math.cos((TIME + 2)/10)) * 0.5
    if math.random() > 0.6 then
        Bubble.new(pos, vec(0,0.1,0) + vec(math.sin(TIME/10),0,math.cos(TIME/10)) * 0.12)
        for _ = 1, 3 do
            particles["bubble_pop"]:pos(pos):scale(1.2):spawn()
            particles["splash"]:pos(pos + rng.vec3() * 0.1):scale(0.5):spawn()
        end
    end
    if skull.data.overdrive > 0 then
        for i = 1, 5 do
            Bubble.new(pos, vec(0,0.1,0) + rng.vec3():normalize() * 0.15 + vec(math.sin(TIME/10),0,math.cos(TIME/10)) * 0.1)
            for _ = 1, 2 do
                particles["bubble_pop"]:pos(pos):scale(1.2):spawn()
                particles["splash"]:pos(pos + rng.vec3() * 0.1):scale(0.5):spawn()
            end
        end
        skull.data.overdrive = skull.data.overdrive - 1
    end
end

---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)
    skull.data.overdrive = 6
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)
    skull.data.part.Gun:rot(utils.dirToAngle(vec(math.sin((TIME + delta)/10),0.6,math.cos((TIME + delta)/10))) + vec(0,skull.rot,0))
end

---@param skull Skull
function day:exit(skull)

end

---@param skulls Skull[]
function day:globalTick(skulls)

end

---@param skulls Skull[]
---@param delta number
function day:globalRender(skulls, delta)

end

---@param skulls Skull[]
function day:globalInit(skulls)

end

---@param skulls Skull[]
function day:globalExit(skulls)

end

---@param entity Entity
function day:wornInit(entity)

end

---@param entity Entity
function day:wornTick(entity)
    if math.random() > 0 then
        Bubble.new(entity:getPos():add(0, entity:getBoundingBox().y + 0.1, 0) + entity:getLookDir() * 0.5, entity:getLookDir() * 0.5)
    end
end

---@param entity Entity
---@param delta number
function day:wornRender(entity, delta)

end

---@param entity Entity
function day:wornExit(entity)

end
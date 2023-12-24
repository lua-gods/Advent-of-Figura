local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("cat")
local Anim = require("libraries.Anim")


local cat = models.cat.Cat
local worn_part = day:addWornPart(cat)
local item_part = day:setItemPart(cat)

local idle = Anim.new(models.cat, "idle")

idle:play()


--control variables
local eepyTime = 60 --time before falling asleep(seconds)


---@param skull Skull
function day:init(skull)
    skull.data.cat = skull:addPart(cat)
    skull.data.sleeping = false
    skull.data.timeAwake = 0
end

---@param skull Skull
function day:tick(skull)
    --falls asleep after a while
   skull.data.timeAwake = skull.data.timeAwake + 1
   if skull.data.timeAwake > eepyTime*20 then
        skull.data.sleeping = true
   else
        skull.data.sleeping = false
   end
end

---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)
    if skull.data.sleeping then
        --wake up
        skull.data.sleeping = false
    else
        --random anim
    end
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)

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

end

---@param entity Entity
---@param delta number
function day:wornRender(entity, delta)

end

---@param entity Entity
function day:wornExit(entity)

end
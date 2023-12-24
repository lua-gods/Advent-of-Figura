local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("cat")
local Anim = require("libraries.Anim")


local cat = models.cat.Cat
local worn_part = day:addWornPart(cat)
local item_part = day:setItemPart(cat)




--control variables
local eepyTime = 3 --time before falling asleep(seconds)


---@param skull Skull
function day:init(skull)
    --skull.data.cat = skull:addPart(cat)
    skull.data.sleeping = false
    skull.data.timeAwake = 0
    local copy = skull:addPart(models.cat)
    skull.data.idle = Anim.new(copy, "idle")
    skull.data.sleep = Anim.new(copy, "sleep")
    skull.data.fallAsleep = Anim.new(copy, "fallAsleep")
    skull.data.idle:play()
end

---@param skull Skull
function day:tick(skull)
    --falls asleep after a while
   skull.data.timeAwake = skull.data.timeAwake + 1
   if skull.data.timeAwake > eepyTime*20 then
        skull.data.sleeping = true
        skull.data.idle:stop()
        skull.data.fallAsleep:play()
   else
        skull.data.sleeping = false
   end
   if skull.data.sleeping then
    if skull.data.fallAsleep.time >= .66 then
        skull.data.fallAsleep:stop()
        skull.data.sleep:play()
    end
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
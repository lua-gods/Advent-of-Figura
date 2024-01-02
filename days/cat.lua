local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("cat")
local Anim = require("libraries.Anim")







--control variables
local eepyTime = 10 --time before falling asleep(seconds)

--interaction function
local function interact(skull)
    skull.data.randomInteractionCooldown = 300
    for i, v in ipairs(skull.data.interactions) do
        v:stop() --overrides any currently playing interaction
        v.time = 0
    end
    skull.data.idle:play()

    skull.data.interactions[math.random(1, #skull.data.interactions)]:play()
end



---@param skull Skull
function day:init(skull)
    --skull.data.cat = skull:addPart(cat)
    skull.data.sleeping = false
    skull.data.timeAwake = 0
    skull.data.randomInteractionCooldown = 300
    local copy = skull:addPart(models.cat)
    skull.data.idle = Anim.new(copy, "idle")
    skull.data.sleep = Anim.new(copy, "sleep")
    skull.data.fallAsleep = Anim.new(copy, "fallAsleep")
    skull.data.wakeUp = Anim.new(copy, "wakeUp")
    skull.data.summon = Anim.new(copy, "summonthee")
    skull.data.idle:play()
    skull.data.interactions = {
        Anim.new(copy, "interact1"),
        Anim.new(copy, "interact2"),
        Anim.new(copy, "interact3"),
        Anim.new(copy, "interact4"),
        Anim.new(copy, "interact5"),
        Anim.new(copy, "interact6"),
        Anim.new(copy, "interact7"),
        Anim.new(copy, "interact8"),
        Anim.new(copy, "interact9"),
        Anim.new(copy, "interact10")
    }
end

---@param skull Skull
function day:tick(skull)

    --sounds:playSound("minecraft:entity.cat.ambient", skull.render_pos, .5, .6)
    --falls asleep after a while
   skull.data.timeAwake = skull.data.timeAwake + 1
   if skull.data.timeAwake > eepyTime*20 then --runs when it's been awake too long
        skull.data.sleeping = true
        skull.data.idle:stop()
        skull.data.fallAsleep:play()
   else
        skull.data.sleeping = false
   end

   --idles
   if skull.data.sleeping then --runs when sleeping
        if skull.data.fallAsleep.time >= skull.data.fallAsleep.length then --waits for fallAsleep to finish(runs constantly after)
            skull.data.fallAsleep:stop()
            skull.data.sleep:play()
        end
    else
        if skull.data.wakeUp.time >= skull.data.wakeUp.length then --same as above but for wakeUp
            skull.data.wakeUp:stop()
            skull.data.idle:play()
        end
    end

    --interactions
    local interactionstop = false
    local interacting = false
    for i, v in ipairs(skull.data.interactions) do
        if v.time >= v.length then
            interactionstop = true
            v.time = 0
            v:stop()
        elseif v.time ~= 0 then --when an anim is playing
            interacting = true
        end

    end
    
    if interactionstop then
        skull.data.idle:play()
    elseif interacting then
        skull.data.idle:stop()
        skull.data.timeAwake = 0
    end
    
    --randomly plays an interaction animation for fun
    if not skull.data.sleeping and math.random(1, 600) == 1 and skull.data.randomInteractionCooldown == 0 then
        interact(skull)
    end
    --prevents overdone repitition
    if skull.data.randomInteractionCooldown > 0 then
        skull.data.randomInteractionCooldown = skull.data.randomInteractionCooldown - 1
    end
end



---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)
    if skull.data.sleeping then --wake up punch
        skull.data.wakeUp.time = 0
        skull.data.sleeping = false
        skull.data.wakeUp:play()
        skull.data.sleep:stop()
        skull.data.timeAwake = 0
        skull.data.fallAsleep.time = 0
        skull.data.fallAsleep:stop()
        skull.data.randomInteractionCooldown = 300
    
    else --interact punch
        interact(skull)
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
local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("door_wreath", 20)

function toggleDoorHoligram(skull,toggle)
  if toggle then
    skull.data.door_wreath.door:setVisible(true)
    skull.data.door_wreath.door:setPrimaryRenderType("TRANSLUCENT_CULL")
    skull.data.door_wreath:setLight(15)
    skull.data.door_wreath.wreath:setPos(0,52,-12)
    skull.data.door_wreath.block:setVisible(true)
    skull.data.door_wreath.block:setPrimaryRenderType("SOLID")
    skull.data.door_wreath.block:setColor(0.5,0.5,0.5)
    skull.data.door_wreath.block:setOpacity(0.5)
  else
    skull.data.door_wreath.door:setVisible(false)
    skull.data.door_wreath.block:setVisible(false)
  end
end

---@param skull Skull
function day:init(skull)
  skull.data.door_wreath = skull:addPart(models.door_wreath)
  if not skull.is_wall_head then
    toggleDoorHoligram(skull,true)
  end

end

---@param skull Skull
function day:tick(skull)
  if skull.is_wall_head then return end
  skull.data.door_wreath:setLight(world.getLightLevel(skull.pos + vec(0,2,0)))
  local door = world.getBlockState(skull.pos + vec(0,2,0))
  if string.find(door.id,"door") then
    toggleDoorHoligram(skull,false)
    local properties = door:getProperties()
    if properties.hinge == "right" then
      skull.data.door_wreath.wreath:setScale(-1,1,1)
    else
      skull.data.door_wreath.wreath:setScale(1,1,1)
    end
    if properties.open == "true" then
      skull.data.door_wreath.wreath.open:setRot(0,90,0)
      skull.data.door_wreath.wreath.open:setPos(-4,0,0)
    else
      skull.data.door_wreath.wreath.open:setRot(0,0,0)
      skull.data.door_wreath.wreath.open:setPos(0,0,0)
    end
  else
    toggleDoorHoligram(skull,true)
  end
end

---@param skull Skull
function day:punch(skull)

end

---@param skull Skull
---@param delta number
function day:render(skull, delta)
  skull.data.door_wreath.door:setOpacity(math.sin((world.getTime()+delta)/5)/4+0.75)
end

---@param skull Skull
function day:exit(skull)

end
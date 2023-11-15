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
    skull.data.door_wreath.wreath.open:setRot(0,0,0)
    skull.data.door_wreath.wreath.open:setPos(0,0,0)
  end
end

---@param skull Skull
function day:init(skull)
  skull.data.door_wreath = skull:addPart(models.door_wreath)
  if not skull.is_wall_head then
    toggleDoorHoligram(skull,true)
    skull.data.door_wreath:setRot(0,math.floor(-skull.rot/90)*90,0)
  end

end

---@param skull Skull
function day:tick(skull)
  if skull.is_wall_head then return end
  skull.data.door_wreath:setLight(world.getLightLevel(skull.pos + vec(0,2,0)))
  local door = world.getBlockState(skull.pos + vec(0,2,0))
  local properties = door:getProperties()
  if string.find(door.id,"door") and not string.find(door.id,"trap") then
    toggleDoorHoligram(skull,false)
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
  if skull.is_wall_head then return end
  
  local door = world.getBlockState(skull.pos + vec(0,2,0))
  if string.find(door.id,"door") and not string.find(door.id,"trap") then
    local properties = door:getProperties()
    local mod = 0
    -- tried to do this with vectors. Didn't work. Got mad. Here's your dumb hardcoded solution, I don't even care anymore ;w;
    local headDir = -(math.floor(-skull.rot/90)*90)
    if headDir == 360 then
      headDir = 0
    end
    local NS = headDir == 0 and properties.facing == "north"
    local WE = headDir == 270 and properties.facing == "west"
    local SN = headDir == 180 and properties.facing == "south"
    local EW = headDir == 90 and properties.facing == "east"
    local backsideReef = (NS or WE or SN or EW)
    if properties.hinge == "right" then
      mod = 1
    else
      mod = -1
    end
    if properties.open == "true" then
      if not backsideReef then
        skull.data.door_wreath.wreath.open:setPivot(-9*mod,4,3)
        skull.data.door_wreath.wreath.open:setRot(0,-90*mod,0)
        skull.data.door_wreath.wreath.open:setPos(4*mod,0,0)
      else
        skull.data.door_wreath.wreath.open:setPivot(-9*mod,4,16)
        skull.data.door_wreath.wreath.open:setRot(0,90*mod,0)
        skull.data.door_wreath.wreath.open:setPos(26*mod,0,5)
      end
    else
      if not backsideReef then
        skull.data.door_wreath.wreath.open:setPivot(-9*mod,4,3)
        skull.data.door_wreath.wreath.open:setRot(0,0,0)
        skull.data.door_wreath.wreath.open:setPos(0,0,0)
      else
        skull.data.door_wreath.wreath.open:setPivot(-9*mod,4,16)
        skull.data.door_wreath.wreath.open:setRot(0,0,0)
        skull.data.door_wreath.wreath.open:setPos(0,0,13)
      end
    end
  else
    skull.data.door_wreath.door:setOpacity(math.sin((TIME+delta)/5)/4+0.75)
  end
end

---@param skull Skull
function day:exit(skull)

end
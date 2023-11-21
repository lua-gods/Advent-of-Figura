local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("snowfall")
local SkullRenderer = require("libraries.SkullRenderer")
local renderer = SkullRenderer.new()
local customRain = nil
local groundSnowDatabase = {}
local fallingSnowDatabase = {}
local clientPos = nil

local function deepCopy(model)
  local copy = model:copy(model:getName())
  for _, child in pairs(copy:getChildren()) do
      copy:removeChild(child):addChild(deepCopy(child))
  end
  return copy
end

function day:globalInit(skull)
  clientPos = client.getViewer():getPos()
  renderer:addPart(models.customRain)
  for k,v in pairs(renderer.parts) do
    if v:getName() == "customRain" then
      customRain = v
    end
  end
  for x = -10, 10 do
    for z = -10, 10 do
      if math.sqrt(x^2+z^2) < 10 and not (x == 0 and z == 0) then
        customRain:newPart(tostring(vec(x,z)))
        :setPos((x)*16,160,(z)*16)
        :setPivot(-8,0,-8)
        :setRot(0,math.deg(math.atan2(x,z)),0)
        customRain[tostring(vec(x,z))]:addChild(customRain.template:copy('cube'))
        :setUVMatrix(matrices.scale3(1,5,1))
        fallingSnowDatabase[tostring(vec(x,z))] = vec(x,z)
      end
    end
  end
  models.customRain:setVisible(true)
  customRain:removeChild(customRain.template)

end

function day:globalExit(skulls)
  renderer:reset()
end

function day:globalTick(skulls)
  clientPos = client.getViewer():getPos()
  models.customRain:setPos((math.floor(clientPos.x)+0.5)*16,(math.floor(clientPos.y)+0.5)*16,(math.floor(clientPos.z)+0.5)*16)
  for k,v in pairs(customRain:getChildren()) do
    v:setVisible(false)
  end
  for x = -10, 10 do
    for z = -10, 10 do
      if math.sqrt(x^2+z^2) < 10 and not (x == 0 and z == 0) then
        local pos = vec(math.floor(clientPos.x)+x,math.floor(clientPos.z)+z)
        for k,v in pairs(groundSnowDatabase) do
          if v[tostring(pos)] then
            customRain[tostring(vec(x,z))]:setVisible(true)
            local scale = math.clamp((math.floor(clientPos.y) - v[tostring(pos)].headPos.y + 10)/20,0,1)
            customRain[tostring(vec(x,z))]:setScale(1,scale,1)
          end
        end
      end
    end
  end
end

function events.render(delta)
  for k,pos in pairs(fallingSnowDatabase) do
    for i,j in pairs(groundSnowDatabase) do
      local snowID = vec(math.floor(clientPos.x) + pos.x,math.floor(clientPos.z) + pos.y)
      if j[tostring(snowID)] then
        local floorSnow = j[tostring(snowID)]
        local fallingSnow = customRain[k]
        local scale = fallingSnow:getScale().y
        local vel = floorSnow.snowVel
        fallingSnow:setUVMatrix(matrices.scale3(1,5*scale,1):translate((TIME+delta)/100*vel.x,(TIME+delta)/100*vel.y))
      end
    end
  end
end

local function reloadSnow(skull)
  groundSnowDatabase[tostring(skull.pos)] = {}
  for x = -8, 8 do
    for z = -8, 8 do
      if not (x == 0 and z == 0) and math.sqrt(x^2+z^2) < 8 then
        for y = -20, 10 do
          y = -y
          local blockPos = skull.pos+vec(x,y,z)
          local blockstate = world.getBlockState(blockPos) 
          if not blockstate:isAir() and world.getBlockState(blockPos+vec(0,1,0)):isAir() then
            local alreadyExists = false
            for k,v in pairs(groundSnowDatabase) do
              if v[tostring(vec(blockPos.x,blockPos.z))] then
                alreadyExists = true
              end
            end
            if not alreadyExists then
              groundSnowDatabase[tostring(skull.pos)][tostring(vec(blockPos.x,blockPos.z))] = {
                snowPos = vec(x,y,z),
                headPos = blockPos,
                snowVel = vec(bit32.rrotate(blockPos.x+blockPos.z,16) % 200/100 - 1,(bit32.rrotate(blockPos.x+blockPos.z,15) % 200/200 - 2)/2),
                snowScale = 1
              }
              local blockHeight = 0
              if blockstate:getCollisionShape()[1] then
                blockHeight = blockstate:getCollisionShape()[1][2][2]
              end
              if not world.getBlockState(blockPos+vec(0,-1,0)):hasCollision() and not blockstate:hasCollision() then
                blockHeight = blockHeight-1
              end
              if string.find(blockstate.id,"head") then
                blockHeight = 0
              end
              skull.data.snowfall.snow:newPart(tostring(vec(x,z)))
--[[               --- debug
              skull.data.snowfall.snow:setColor(math.random(0,10)/10,math.random(0,10)/10,math.random(0,10)/10)
              --- ]]
              skull.data.snowfall.snow[tostring(vec(x,z))]:addChild(skull.data.snowfall.snow.snow)
              skull.data.snowfall.snow[tostring(vec(x,z))]:setPos(x*16,(blockPos.y+blockHeight-skull.pos.y)*16,z*16)
              if string.find(blockstate.id,"stairs") and blockHeight ~= 1 then
                skull.data.snowfall.snow[tostring(vec(x,z))]:addChild(skull.data.snowfall.snow.stair:copy("stair"))
                skull.data.snowfall.snow[tostring(vec(x,z))].stair:setVisible(true)
                for k,v in pairs({"north","east","south","west"}) do
                  if v == blockstate:getProperties().facing then
                    skull.data.snowfall.snow[tostring(vec(x,z))].stair:setRot(0,(k-1)*-90,0)
                  end
                end
                skull.data.snowfall.snow[tostring(vec(x,z))].stair:setVisible(true)
              end
            end
          end
        end

      end
    end
  end
end

---@param skull Skull
function day:init(skull)
  skull.data.snowfall = skull:addPart(models.snowfall)
  skull.data.snowfall:setRot(0,0,0)
  reloadSnow(skull)
end

---@param skull Skull
function day:tick(skull)

end

---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)
  reloadSnow(skull)
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)

end

---@param skull Skull
function day:exit(skull)
  groundSnowDatabase[tostring(skull.pos)] = nil
end
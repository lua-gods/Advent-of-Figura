local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("snowfall")
snowfallDatabase = {}

local function deepCopy(model)
  local copy = model:copy(model:getName())
  for _, child in pairs(copy:getChildren()) do
      copy:removeChild(child):addChild(deepCopy(child))
  end
  return copy
end

local function reloadSnow(skull)
  snowfallDatabase[tostring(skull.pos)] = {}
  for x = -8, 8 do
    for z = -8, 8 do
      if not (x == 0 and z == 0) and math.sqrt(x^2+z^2) < 8 then
        for y = -10, 20 do
          local blockPos = skull.pos+vec(x,y,z)
          local blockstate = world.getBlockState(blockPos) 
          if not blockstate:isAir() and world.getBlockState(blockPos+vec(0,1,0)):isAir() then
            local alreadyExists = false
            for k,v in pairs(snowfallDatabase) do
              if v[tostring(blockPos)] then
                alreadyExists = true
              end
            end
            if not alreadyExists then
              snowfallDatabase[tostring(skull.pos)][tostring(blockPos)] = {
                rootSkull = tostring(skull.pos)
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
              skull.data.snowfall.snow:newPart("x"..x.."z"..z)
--[[               --- debug
              skull.data.snowfall.snow:setColor(math.random(0,10)/10,math.random(0,10)/10,math.random(0,10)/10)
              --- ]]
              skull.data.snowfall.snow["x"..x.."z"..z]:addChild(skull.data.snowfall.snow.snow)
              skull.data.snowfall.snow["x"..x.."z"..z]:setPos(x*16,(blockPos.y+blockHeight-skull.pos.y)*16,z*16)
              if string.find(blockstate.id,"stairs") and blockHeight ~= 1 then
                skull.data.snowfall.snow["x"..x.."z"..z]:addChild(deepCopy(skull.data.snowfall.snow.stair))
                skull.data.snowfall.snow["x"..x.."z"..z].stair:setVisible(true)
                for k,v in pairs({"north","east","south","west"}) do
                  if v == blockstate:getProperties().facing then
                    skull.data.snowfall.snow["x"..x.."z"..z].stair:setRot(0,(k-1)*-90,0)
                  end
                end
                skull.data.snowfall.snow["x"..x.."z"..z].stair:setVisible(true)
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
  local particlePos = skull.pos + vec(math.random(-8,8),math.random(20,30),math.random(-8,8))
  if math.sqrt((particlePos.x-skull.pos.x)^2+(particlePos.z-skull.pos.z)^2) < 8 then
    particles:newParticle("minecraft:snowflake",particlePos):setLifetime(500)
  end
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
  snowfallDatabase[tostring(skull.pos)] = nil
end
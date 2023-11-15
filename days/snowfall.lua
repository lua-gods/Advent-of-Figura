local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("snowfall")
--local snowfallDatabase = {}

local function reloadSnow(skull)
  for x = -6, 6 do
    for z = -6, 6 do
      if not (x == 0 and z == 0) and math.sqrt(x^2+z^2) < 6 then
        for y = -6, 6 do
          local blockPos = skull.pos+vec(x,y,z)
          local blockstate = world.getBlockState(blockPos) 
          if not blockstate:isAir() and world.getBlockState(blockPos+vec(0,1,0)):isAir() then
            local blockHeight = 0
            if blockstate:getCollisionShape()[1] then
              blockHeight = blockstate:getCollisionShape()[1][2][2]
            end
            skull.data.snowfall.snow:newPart("x"..x.."z"..z)
            skull.data.snowfall.snow["x"..x.."z"..z]:addChild(skull.data.snowfall.snow.snow)
            skull.data.snowfall.snow["x"..x.."z"..z]:setPos(x*16,(blockPos.y+blockHeight-skull.pos.y)*16,z*16)
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
  --snowfallDatabase[tostring(skull.pos)] = "temp"
  reloadSnow(skull)
end

---@param skull Skull
function day:tick(skull)
  local particlePos = skull.pos + vec(math.random(-6,6),math.random(20,30),math.random(-6,6))
  if math.sqrt((particlePos.x-skull.pos.x)^2+(particlePos.z-skull.pos.z)^2) < 6 then
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

end
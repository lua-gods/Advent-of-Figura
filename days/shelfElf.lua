local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("shelfElf")

---@param skull Skull
function day:init(skull)
  skull.hasJumpscared = true
  skull.isntFirstTick = false
  skull.data.model = skull:addPart(models.shelfElf)
end

local maxCeilingHeight = 5 
local function checkCeilng(clientPos)
  local likleyCeiling = 0
  for k = 1, maxCeilingHeight do
    if world.getBlockState(clientPos+vec(0,k,0)):hasCollision() then
      return k
    end
  end
  return maxCeilingHeight
end

local function isOnScreen(worldPos)
  screenPos = vectors.worldToScreenSpace(worldPos)
  return (-2 < screenPos.x and screenPos.x < 2) and (-2 < screenPos.y and screenPos.y < 2) and screenPos.z > 1
end

local denyList = {"head","door"}
---@param skull Skull
function day:tick(skull)
  if not skull.isntFirstTick then skull.isntFirstTick = true return end
  local clientPos = client.getViewer():getPos()
  local headPos = skull.data.model.ROOT:partToWorldMatrix():apply()
  if not isOnScreen(skull.data.model.ROOT:partToWorldMatrix():apply()) then
    local horosontalDistance = math.sqrt((clientPos.x-headPos.x)^2 + (clientPos.z-headPos.z)^2)
    local xRot = math.deg(math.atan2(clientPos.y + 1 - headPos.y,horosontalDistance))
    local yRot = math.deg(math.atan2(clientPos.x - headPos.x,clientPos.z - headPos.z)) - 180
    skull.data.model.ROOT:setRot(vec(0,yRot,0) - skull.data.model:getRot())
    skull.data.model.ROOT.Elf.Head:setRot(xRot,0,0)
    if TIME % 99 == 0 then
      local likleyCeiling = checkCeilng(clientPos)
      local randomPos = vec(skull.pos.x + math.random(-4,4), math.floor(clientPos.y) + likleyCeiling, skull.pos.z + math.random(-4,4))
      for k = 0, 5 + likleyCeiling do
        local pos = randomPos - vec(0,k,0)
        local blockstate = world.getBlockState(pos)
        local aboveBlockstate = world.getBlockState(pos+vec(0,1,0))
        local isDenyListed = false
        local isDenyListedAbove = false
        for i,j in pairs(denyList) do
          if string.find(blockstate.id,j) then
            isDenyListed = true
          end
          if string.find(aboveBlockstate.id,j) then
            isDenyListedAbove = true
          end
        end
        if (blockstate:hasCollision() and not (blockstate.id == "minecraft:light" or isDenyListed)) and (not aboveBlockstate:hasCollision() or aboveBlockstate.id == "minecraft:light" or isDenyListedAbove) then
          local finalPos = pos+vec(0.5,0,0.5)
          if not isOnScreen(finalPos) then
            skull.hasJumpscared = false
            local blockHeight = 0
            if blockstate:getCollisionShape()[1] then
              blockHeight = blockstate:getCollisionShape()[1][2].y
            end
            skull.data.model.ROOT:setPos(skull.data.model:partToWorldMatrix():invert():apply(finalPos) + vec(0,blockHeight*16,0))
          end
        end
      end
    end
  else
    local horosontalDistance = math.sqrt((clientPos.x-headPos.x)^2 + (clientPos.z-headPos.z)^2)
    if (horosontalDistance^2 + (clientPos.y-headPos.y)^2) < 9 and (not skull.hasJumpscared) then
      sounds:playSound("minecraft:ambient.cave",clientPos)
    end
    skull.hasJumpscared = true
  end
end

---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)

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
function day:globalInit(skulls)

end

---@param skulls Skull[]
function day:globalExit(skulls)

end

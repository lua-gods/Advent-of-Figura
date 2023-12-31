local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("shelfElf")

day:setItemPart(models.shelfElf)

local MAX_CEILING_HEIGHT = 5
local DENY_LIST = { "head", "door" }

local function checkCeiling(clientPos)
  for k = 1, MAX_CEILING_HEIGHT do
    if world.getBlockState(clientPos + vec(0, k, 0)):hasCollision() then
      return k
    end
  end
  return MAX_CEILING_HEIGHT
end

local function isOnScreen(worldPos)
  local screenPos = vectors.worldToScreenSpace(worldPos)
  return (-2 < screenPos.x and screenPos.x < 2) and (-2 < screenPos.y and screenPos.y < 2) and
  screenPos.z > 1
end

function day:init(skull)
  skull.data.hasJumpscared = true
  skull.data.isFirstTick = true
  skull.data.model = skull:addPart(models.shelfElf)
  skull.data.pos = skull.pos
  skull.data.rot = vec(0, skull.rot, 0)
end

function day:tick(skull)
  if skull.data.isFirstTick then
    skull.data.isFirstTick = false
    return
  end

  local clientPos = viewer:getPos():add(0,viewer:getEyeHeight(),0)

  if not isOnScreen(skull.data.pos + vec(0.5, 0, 0.5)) then
    local rot = utils.dirToAngle(clientPos - skull.data.pos)
    skull.data.rot = vec(0, rot.y + 180 + skull.rot, 0)
    skull.data.model.ROOT:setRot(skull.data.rot)
    skull.data.model.ROOT.Elf.Head:setRot(-rot.x, 0, 0)

    if TIME % 99 == 0 then
      local likelyCeiling = checkCeiling(clientPos)
      local randomPos = vec(skull.pos.x + math.random(-4, 4), math.floor(clientPos.y) + likelyCeiling, skull.pos.z + math.random(-4, 4))
      for k = 0, 5 + likelyCeiling do
        local pos = randomPos - vec(0, k, 0)
        local blockstate = world.getBlockState(pos)
        local aboveBlockstate = world.getBlockState(pos + vec(0, 1, 0))
        local isDenyListed = false
        local isDenyListedAbove = false
        for _, j in pairs(DENY_LIST) do
          if string.find(blockstate.id, j) then
            isDenyListed = true
          end
          if string.find(aboveBlockstate.id, j) then
            isDenyListedAbove = true
          end
        end
        if (blockstate:hasCollision() and not (blockstate.id == "minecraft:light" or isDenyListed)) and (not aboveBlockstate:hasCollision() or aboveBlockstate.id == "minecraft:light" or isDenyListedAbove) then
          if not isOnScreen(pos  + vec(0.5, 0, 0.5)) then
            skull.data.hasJumpscared = false
            local blockHeight = 0
            if blockstate:getCollisionShape()[1] then
              blockHeight = blockstate:getCollisionShape()[1][2].y
            end
            skull.data.pos = pos + vec(0, blockHeight, 0)
            skull.data.model:setPos(skull.data.pos * 16)
          end
        end
      end
    end
  else
    local horosontalDistance = math.sqrt((clientPos.x-skull.data.pos.x)^2 + (clientPos.z-skull.data.pos.z)^2)
    if (horosontalDistance^2 + (clientPos.y-skull.data.pos.y)^2) < 9 and (not skull.data.hasJumpscared) then
      sounds:playSound("minecraft:ambient.cave",clientPos)
    end
      skull.data.hasJumpscared = true
      end
end
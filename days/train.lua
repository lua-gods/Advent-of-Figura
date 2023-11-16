local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("train")

local skullManager = require("libraries.SkullManager")
local SkullRenderer = require("libraries.SkullRenderer")
local deepCopy = require("libraries.deep_copy")
local modeGetter = require("libraries.mode_getter")

-- settings
local trainSpeed = 0.15

-- place indicator
local placeIndicatorRenderer = SkullRenderer:new()
local placeIndicatorModel = deepCopy(models.train)
local placeIndicatorPreviousModel = nil
placeIndicatorRenderer:addPart(placeIndicatorModel)
placeIndicatorModel:setOpacity(0.5)
for _, modelpart in pairs(placeIndicatorModel:getChildren()) do
   modelpart:setVisible(false)
end

local normals = {
   up = vec(0, 1, 0),
   down = vec(0, -1, 0),
   west = vec(-1, 0, 0),
   east = vec(1, 0, 0),
   south = vec(0, 0, 1),
   north = vec(0, 0, -1)
}

-- facing to rot
local facingToRot = {
   west = -90,
   east = 90,
   south = 0,
   north = 180,
}

-- functions
local function getNextTrack(skull, startNode)
   local nextPos = skull.pos + (startNode and skull.data.startNode or skull.data.endNode)
   -- nextPos = (nextPos + 0.5):floor()
   local newSkull = skullManager:get(nextPos)
   if not (newSkull and newSkull.data.isTrain) then
      nextPos.y = nextPos.y - 1
      newSkull = skullManager:get(nextPos)
   end
   if newSkull and newSkull.data.isTrain then
      local connectedEndPos = nextPos + newSkull.data.endNode
      local backwards = connectedEndPos == skull.pos or connectedEndPos - vec(0, 1, 0) == skull.pos
      local connectedStartPos = nextPos + newSkull.data.startNode
      if backwards or connectedStartPos == skull.pos or connectedStartPos - vec(0, 1, 0) == skull.pos then
         return newSkull, backwards
      end
   end
end

local function findTrainNearby(skull)
   local pos = skull.pos
   for direction = 0, 1 do
      local startNode = direction == 1
      local currentSkull
      currentSkull, startNode = getNextTrack(skull, startNode)
      for _ = 1, 16 do
         if not currentSkull or currentSkull.pos == pos then
            break
         end
         if currentSkull.data.train then
            return skull
         end

         currentSkull, startNode = getNextTrack(currentSkull, startNode)
      end
   end
end

local function selectTrackType(blockRot, blockFacing)
   local trackType, model, startNode, endNode, rotOffset
   if blockFacing then
      trackType = 'vertical'
      local rot = facingToRot[blockFacing]
      model = models.train.vertical
      startNode = vec(0, 0, 1) * matrices.rotation3(0, rot, 0)
      endNode = vec(0, 1, 0) - startNode
      rotOffset = rot
   elseif blockRot % 4 == 0 then
      trackType = 'straight'
      model = models.train.straight
      startNode = blockRot % 8 == 0 and vec(0, 0, 1) or vec(1, 0, 0)
      endNode = -startNode
      rotOffset = blockRot % 8 == 0 and 0 or 90
   else
      trackType = 'curve'
      local rot = math.floor(blockRot / 4) * -90
      model = models.train.curve
      local mat = matrices.rotation3(0, rot, 0)
      startNode = vec(0, 0, 1) * mat
      endNode = vec(1, 0, 0) * mat
      rotOffset = rot
   end
   startNode = (startNode + 0.5):floor()
   endNode = (endNode + 0.5):floor()
   return trackType, rotOffset, model, startNode, endNode
end

--- runs every time a skull is loaded.
---@param skull Skull
function day:init(skull)
   skull.data.isTrain = true
   -- find correct track type
   local block = world.getBlockState(skull.pos)
   local blockRot = block.properties.rotation or 0
   local blockFacing = block.properties.facing
   skull.data.trackType, skull.data.rotOffset, skull.data.model, skull.data.startNode, skull.data.endNode = selectTrackType(blockRot, blockFacing)
   -- set track model
   skull.data.model = skull:addPart(skull.data.model)
   skull.data.model:setRot(0, skull.data.rotOffset, 0)
   skull.data.model:setPos(skull.pos * 16)
   -- add train model
   skull.data.trainModel = skull:addPart(models.train.train):setVisible(false)
   skull.data.spawnTrainTime = 3
end

--- every world tick.
---@param skull Skull
function day:tick(skull)
   -- spawn train
   skull.data.spawnTrainTime = math.max(skull.data.spawnTrainTime - 1, 0)
   if skull.data.spawnTrainTime == 1 then
      -- spawn train if it doesnt exist on track already
      if not findTrainNearby(skull) then
         skull.data.train = {
            oldTime = 0.5,
            time = 0.5,
            backwards = false,
            speed = trainSpeed,
            tick = 0
         }
      end
   end
   -- move into another skull
   local train = skull.data.train
   if train and train.tick ~= TIME then
      train.tick = TIME
      -- update time and speed
      train.oldTime = train.time
      local speed = train.speed
      train.speed = math.lerp(train.speed, trainSpeed, 0.4)
      -- adjust speed for some rail types
      if skull.data.trackType == 'rotated' then
         speed = speed * 1.6
      elseif skull.data.trackType == 'vertical' then
         speed = speed * (train.backwards and 1.2 or 0.8)
      end
      train.time = train.time + speed
      -- try to move to next rail
      if train.time >= 1 then
         train.oldTime = train.oldTime % 1 - 1
         train.time = train.time % 1
         local newSkull, backwards = getNextTrack(skull, train.backwards)
         if newSkull and not newSkull.data.train then
            train.backwards = backwards
            newSkull.data.train = train
            skull.data.train = nil
         end
      elseif train.time >= 0.5 then -- try turning backwards
         local newSkull = getNextTrack(skull, train.backwards)
         if not newSkull or newSkull.data.train then
            newSkull = getNextTrack(skull, not train.backwards)
            if not newSkull or newSkull.data.train then -- stop moving
               train.speed = 0
               train.time = 0.5
            else -- turn backwards
               train.speed = -0.05
               train.time = 0.5
               train.oldTime = 0.5
               train.backwards = not train.backwards
            end
         end
      end
   end
end

--- when the skull is punched.
---@param skull Skull
function day:punch(skull) -- i dont think i will need it
   -- log("ouch")
end

local function renderTrain(skull, time, trainModel, backwards)
   local rotOffset = skull.data.rotOffset
   -- time = time / 16 * 17.6
   if skull.data.trackType == 'straight' then
      trainModel:setPos(skull.pos * 16)
      trainModel.start:setPos(0, 0, time * -16)
      trainModel:setRot(0, rotOffset + (backwards and 180 or 0), 0)
      trainModel.start:setRot(0, 0, 0)
      trainModel.start:setPivot(0, 0, 0)
   elseif skull.data.trackType == 'curve' then
      trainModel.start:setPos(0, 0, 0)
      local rot = time * 90
      trainModel:setRot(0, rotOffset, 0)
      trainModel.start:setPos(0, 0, 0)
      if backwards then
         trainModel:setPos(skull.pos * 16 + vec(16, 0, 0) * matrices.rotation3(0, rotOffset, 0))
         trainModel.start:setPivot(-8, 0, 8)
         trainModel.start:setRot(0, rot + 90, 0)
      else
         trainModel:setPos(skull.pos * 16)
         trainModel.start:setPivot(8, 0, 8)
         trainModel.start:setRot(0, -rot, 0)
      end
   elseif skull.data.trackType == 'vertical' then
      time = time * 16
      trainModel:setPos(skull.pos * 16)
      trainModel:setRot(0, rotOffset + 180, 0)
      trainModel.start:setPivot(0, 0, 0)
      if backwards then
         trainModel.start:setRot(-45, 0, 0)
         trainModel.start:setPos(0, 12 - time, 4 - time)
      else
         trainModel.start:setRot(45, 180, 0)
         trainModel.start:setPos(0, 4 + time, time - 4)
      end
   end
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)
   -- render train
   local train = skull.data.train
   local trainModel = skull.data.trainModel
   if train then
      trainModel:setVisible(true)
      local time = math.lerp(train.oldTime, train.time, delta)
      if time < 0 then
         local previousSkull, backwards = getNextTrack(skull, not train.backwards)
         if previousSkull then
            renderTrain(previousSkull, time + 1, trainModel, not backwards)
         else
            renderTrain(skull, time, trainModel, train.backwards)
         end
      else
         renderTrain(skull, time, trainModel, train.backwards)
      end
   else
      skull.data.model:setColor()
      trainModel:setVisible(false)
   end
end

---called when the skull is destroyed, unloaded, or switched to a different day. Do cleanup here.
---@param skull Skull
function day:exit(skull)
   local train = skull.data.train
   if train then
      if not findTrainNearby(skull) then
         local newSkull, backwards = getNextTrack(skull, train.backwards)
         if newSkull then
            train.backwards = backwards
            newSkull.data.train = train
         else
            newSkull, backwards = getNextTrack(skull, not train.backwards)
            if newSkull then
               train.backwards = backwards
               newSkull.data.train = train
            end
         end
      end
   end
end

function day:globalTick()
   if placeIndicatorPreviousModel then
      placeIndicatorPreviousModel:setVisible(false)
      placeIndicatorPreviousModel = nil
   end
   -- stop if not holding head
   if modeGetter.fromItem(viewer:getItem(1)) ~= day then
      return
   end
   local block, pos, side = viewer:getTargetedBlock(true, 5)
   -- stop if not looking at block or looking at bottom of block
   if block:isAir() or side == 'down' then
      return
   end
   -- offset pos
   pos = pos + normals[side] * 0.99
    -- stop if place block is not air
   if not world.getBlockState(pos):isAir() then
      return
   end
   -- stop if not touching any other rail
   local touching = false
   for _, v in pairs(normals) do
      local neighbourBlock = world.getBlockState(pos + v)
      if neighbourBlock.id == 'minecraft:player_head' or neighbourBlock.id == 'minecraft:player_wall_head' then
         local data = neighbourBlock:getEntityData()
         if data and data.SkullOwner and data.SkullOwner.Id and avatar:getUUID() == client.intUUIDToString(table.unpack(data.SkullOwner.Id)) then
            touching = true
            break
         end
      end
   end
   if not touching then
      return
   end
   -- get correct track type
   local rot = math.round(player:getRot().y / 22.5) % 16
   local facing
   if side ~= "up" then facing = side end
   local trackType, rotOffset = selectTrackType(rot, facing)
   -- render model
   local model = placeIndicatorModel[trackType]
   placeIndicatorPreviousModel = model
   model:setVisible(true)
   model:setPos(pos:floor() * 16)
   model:setRot(0, rotOffset, 0)
end

function day:globalExit()
   if placeIndicatorPreviousModel then
      placeIndicatorPreviousModel:setVisible(false)
      placeIndicatorPreviousModel = nil
   end
end
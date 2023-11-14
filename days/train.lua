local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("train", 16) -- name and day number.

local skullManager = require("libraries.SkullManager")

local trainSpeed = 0.1

local facingToRot = {
   west = -90,
   east = 90,
   south = 0,
   north = 180,
}

local function getNextTrack(skull, startNode)
   local nextPos = skull.pos + (startNode and skull.data.startNode or skull.data.endNode)
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

--- runs every time a skull is loaded.
---@param skull Skull
function day:init(skull)
   skull.data.isTrain = true
   -- find correct track type
   local block = world.getBlockState(skull.pos)
   local blockRot = block.properties.rotation or 0
   if block.properties.facing then -- vertical
      skull.data.trackType = 'vertical'
      local rot = facingToRot[block.properties.facing]
      skull.data.model = skull:addPart(models.train.up)
      skull.data.startNode = vec(0, 0, 1) * matrices.rotation3(0, rot, 0)
      skull.data.endNode = vec(0, 1, 0) - skull.data.startNode
      skull.data.rotOffset = rot
      skull.data.debugColor = vec(0, 1, 0)
   elseif blockRot % 4 == 0 then
      skull.data.trackType = 'straight'
      skull.data.model = skull:addPart(models.train.straight)
      skull.data.startNode = blockRot % 8 == 0 and vec(0, 0, 1) or vec(1, 0, 0)
      skull.data.endNode = -skull.data.startNode
      skull.data.rotOffset = blockRot % 8 == 0 and 0 or 90
      skull.data.debugColor = vec(1, 0, 0)
   else
      skull.data.trackType = 'rotated'
      skull.data.debugColor = vec(0, 0, 1)
      local rot = math.floor(blockRot / 4) * -90
      skull.data.model = skull:addPart(models.train.curve)
      local mat = matrices.rotation3(0, rot, 0)
      skull.data.startNode = vec(0, 0, 1) * mat
      skull.data.endNode = vec(1, 0, 0) * mat
      skull.data.rotOffset = rot
   end
   -- set rot and pos of model
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
      -- check if train already exists on track
      -- spawn train if it doesnt exist on track already
      if not findTrainNearby(skull) then
         skull.data.train = {
            oldTime = 0,
            time = 0,
            backwards = false,
            speed = trainSpeed
         }
      end
   end
   -- move into another skull
   local train = skull.data.train
   if train then
      train.oldTime = train.time
      train.time = train.time + train.speed
      train.speed = math.lerp(train.speed, trainSpeed, 0.1)
      if train.time >= 1 then
         train.oldTime = train.oldTime % 1 - 1
         train.time = train.time % 1
         local newSkull, backwards = getNextTrack(skull, train.backwards)
         if newSkull then
            train.backwards = backwards
            newSkull.data.train = train
            skull.data.train = nil
         else
            -- turn backwards
            newSkull, backwards = getNextTrack(skull, not train.backwards)
            if newSkull then
               train.oldTime = 0
               train.time = 0
               train.speed = 0
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

---@param skull Skull
---@param delta number
function day:render(skull, delta)
   -- render train
   local train = skull.data.train
   local trainModel = skull.data.trainModel
   if train then
      trainModel:setVisible(true)
      local trainTime = math.lerp(train.oldTime, train.time, delta)
      skull.data.model:setColor(0.5, 0.5, 0.5)
      local backwards = train.backwards
      local rotOffset = skull.data.rotOffset
      if skull.data.trackType == 'straight' then
         trainModel.start:setPos(0, 0, trainTime * -16)
         trainModel:setRot(0, rotOffset + (backwards and 180 or 0), 0)
      elseif skull.data.trackType == 'rotated' then
         local rot = trainTime * 90
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

      end
   else
      trainModel:setVisible(false)
      skull.data.model:setColor(1, 1, 1)
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

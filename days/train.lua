local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("train", 16) -- name and day number.

local skulls = require("libraries.SkullManager").skulls

-- models.model.days.fallback.cube:setPrimaryTexture("RESOURCE", "missingno") -- do any pre-init stuff here.

local facingToRot = {
   west = -90,
   east = 90,
   south = 0,
   north = 180,
}

local trainCount = 1 -- change later
--- runs every time a skull is loaded.
---@param skull Skull
function day:init(skull)
   skull.data.isTrain = true
   local block = world.getBlockState(skull.pos)
   local blockRot = block.properties.rotation or 0
   if block.properties.facing then
      local rot = facingToRot[block.properties.facing]
      skull.data.model = skull:addPart(models.train.up)
      skull.data.startNode = vec(0, 0, 1) * matrices.rotation3(0, rot, 0)
      skull.data.endNode = vec(0, 1, 0) - skull.data.startNode
      skull.data.rotOffset = rot
      skull.data.debugColor = vec(0, 1, 0)
   elseif blockRot % 4 == 0 then
      skull.data.model = skull:addPart(models.train.straight)
      skull.data.startNode = blockRot % 8 == 0 and vec(0, 0, 1) or vec(1, 0, 0)
      skull.data.endNode = -skull.data.startNode
      skull.data.rotOffset = blockRot % 8 == 0 and 0 or 90
      skull.data.debugColor = vec(1, 0, 0)
   else
      skull.data.debugColor = vec(0, 0, 1)
      local rot = math.floor(blockRot / 4) * -90
      skull.data.model = skull:addPart(models.train.curve)
      local mat = matrices.rotation3(0, rot, 0)
      skull.data.startNode = vec(0, 0, 1) * mat
      skull.data.endNode = vec(1, 0, 0) * mat
      skull.data.rotOffset = rot
   end
   skull.data.trainModel = skull:addPart(models.train.train):setVisible(false)
   if trainCount >= 1 then  -- change later
      trainCount = trainCount - 1
      skull.data.train = {
         oldTime = 0,
         time = 0,
         backwards = false,
      }
   end
end

local function getNextTrack(skull, startNode)
   local nextPos = skull.pos + (startNode and skull.data.startNode or skull.data.endNode)
   local newSkull = skulls[tostring(nextPos)]
   if not (newSkull and newSkull.data.isTrain) then
      nextPos.y = nextPos.y - 1
      newSkull = skulls[tostring(nextPos)]
   end
   if newSkull and not newSkull.data.train then
      local connectedEndPos = nextPos + newSkull.data.endNode
      local backwards = connectedEndPos == skull.pos or connectedEndPos - vec(0, 1, 0) == skull.pos
      return newSkull, backwards
   end
end

--- every world tick.
---@param skull Skull
function day:tick(skull)
   ---[[ -- debug overlay
   if (({ client:getViewer():getTargetedBlock() })[2] or vec(0, 0)):floor() == skull.pos then
      for _ = 1, 10 do
         particles["end_rod"]:pos(skull.pos + vec(math.random(), math.random(), math.random()) +
         skull.data.startNode):color(skull.data.debugColor):lifetime(8):spawn()
         particles["end_rod"]:pos(skull.pos + vec(math.random(), math.random(), math.random()) +
         skull.data.endNode):color(skull.data.debugColor):lifetime(8):spawn()
      end
   end
   --]]
   local train = skull.data.train
   if train then  -- add moving into another head
      train.oldTime = train.time
      train.time = train.time + 0.15
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
               train.oldTime = train.oldTime % 1 - 1
               train.time = train.time % 1
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
function day:render(skull, delta) -- every world render.
   skull.data.model:setRot(0, skull.data.rotOffset, 0)
   skull.data.model:setPos(skull.pos * 16)

   local train = skull.data.train
   local trainModel = skull.data.trainModel
   if train then
      trainModel:setVisible(true)
      local trainTime = math.lerp(train.oldTime, train.time, delta)
      skull.data.trainModel.start:setPos(0, 0, trainTime * -16)
      -- temp train rendering
      trainModel:setRot(0, skull.data.rotOffset + (train.backwards and 180 or 0), 0)
      skull.data.model:setColor(0.5, 0.5, 0.5)
   else
      trainModel:setVisible(false)
      skull.data.model:setColor(1, 1, 1)
   end
end

---called when the skull is destroyed, unloaded, or switched to a different day. Do cleanup here.
---@param skull Skull
function day:exit(skull)
   --  skull.data.flash:remove() -- we'll remove the flash particle we created in init.
end

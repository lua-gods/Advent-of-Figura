local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("train", 16) -- name and day number.

local skulls = require('libraries.SkullManager').skulls

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
    if trainCount >= 1 then -- change later
        trainCount = trainCount - 1
        skull.data.train = {
            oldTime = 0,
            time = 0,
            backwards = true
        }
    end
    -- print(skullManager.skulls)
end

local function getTrainSkull(pos)
    local id = tostring(pos)
    local skull = skulls[id]
    if skull and skull.data.isTrain then
        return skull
    end
end

--- every world tick.
---@param skull Skull
function day:tick(skull)
    -- if skull.data.debugColor.g > 0.5 then
        -- particles["end_rod"]:pos(skull.pos + vec(math.random(),math.random(),math.random()) + skull.data.startNode):color(skull.data.debugColor):lifetime(40):gravity(0):spawn()
        -- particles["end_rod"]:pos(skull.pos + vec(math.random(),math.random(),math.random()) + skull.data.endNode):color(skull.data.debugColor):lifetime(40):gravity(0):spawn()
    -- end
    local train = skull.data.train
    if train then -- add moving into another head
        train.oldTime = train.time
        train.time = train.time + 0.05
        if train.time >= 1 then
            train.oldTime = train.oldTime % 1 - 1
            train.time = train.time % 1
            local nextPos = skull.pos + (train.backwards and skull.data.startNode or skull.data.endNode)
            local newSkull = getTrainSkull(nextPos) or getTrainSkull(nextPos - vec(0, 1, 0))
            if newSkull then
                newSkull.data.train = train
                skull.data.train = nil
                train.backwards = newSkull.pos + newSkull.data.endNode == skull.pos
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
        skull.data.trainModel.start:setPos(0, 0, trainTime * -8)
    else
        trainModel:setVisible(false)
    end
end
---called when the skull is destroyed, unloaded, or switched to a different day. Do cleanup here.
---@param skull Skull
function day:exit(skull)
   --  skull.data.flash:remove() -- we'll remove the flash particle we created in init.
end
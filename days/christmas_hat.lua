local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("christmas_hat")


local hatModel = models.christmas_hat.hat

local wornHat = day:addWornPart(hatModel)
wornHat:setScale(0.9, 0.9, 0.9):setPos(0, 6.5, 0)

---runs every time a skull is loaded.
---@param skull Skull
function day:init(skull)
   skull.data.model = skull:addPart(hatModel)
end

local hatData = {}
function day:wornInit(entity)
   hatData[entity:getUUID()] = {
      oldDir = vec(0, 0),
      dir = vec(0, 2),
      vel = vec(0, 0),
      oldRot = entity:getRot(),
      rot = entity:getRot()
   }
end

function day:wornTick(entity)
   -- get data
   local data = hatData[entity:getUUID()]
   -- update old dir
   data.oldDir = data.dir
   -- rot
   local rot = entity:getRot()
   data.oldRot = data.rot
   data.rot = rot
   local rotVel = rot - data.oldRot
   -- vel
   local vel = entity:getVelocity() * matrices.rotation3(0, rot.y, 0)

   -- physics
   local target = data.dir:normalized()

   data.dir = (data.dir + data.vel):clamped(0, 1.15)
   data.vel = data.vel * 0.5 + (target - data.dir) * 0.1

   data.vel = data.vel + vel.xz * 0.25
   data.vel.y = data.vel.y + rotVel.x * 0.01 - rot.x * 0.002

   data.dir = data.dir * math.clamp(1 + vel.y * 0.1, 0, 1.05)

   data.dir = data.dir * matrices.rotation2(rotVel.y * -0.5)
end

local function rotate(part, angle, len)
   local pivot = part:getPivot()
   part:setMatrix(matrices.translate4(-pivot):rotateY(-angle):rotateX(len):rotateY(angle):translate(pivot))
end

function day:wornRender(entity, delta)
   local data = hatData[entity:getUUID()]
   if not data then return end

   local dir = math.lerp(data.oldDir, data.dir, delta)

   local angle = math.deg(math.atan2(dir.x, dir.y))
   local len = dir:length()
   
   rotate(wornHat.part1, angle, len * 10)
   rotate(wornHat.part1.part2, angle, len * 20)
   rotate(wornHat.part1.part2.part3, angle, len * 70)
   rotate(wornHat.part1.part2.part3.part4, angle, len * 30)
end

function day:wornExit(entity)
   hatData[entity:getUUID()] = nil
end
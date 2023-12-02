local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("snowfall")
local SkullRenderer = require("libraries.SkullRenderer")
local renderer = SkullRenderer.new()
local customRain = nil
local groundSnowDatabase = {}
local fallingSnowDatabase = {}
local clientPos = nil

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
      if x^2+z^2 < 100 and not (x == 0 and z == 0) then
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
  models.customRain:setPos(clientPos:copy():floor():offset(0.5):scale(16))
  local flooredPos = clientPos:copy():floor()
  local fX = flooredPos.x
  local fZ = flooredPos.z
  for k,v in pairs(customRain:getChildren()) do
    v:setVisible(false)
  end
  for i,j in pairs(fallingSnowDatabase) do
    local x = j.x
    local z = j.y
    local pos = vec(fX+x,fZ+z)
    for k,v in pairs(groundSnowDatabase) do
      local val = v[tostring(pos)]
      if val then
        local scale = math.clamp((math.floor(clientPos.y) - val.headPos.y + 10)/20,0,1)
        customRain[tostring(vec(x,z))]:setVisible(true):setScale(1,scale,1)
      end
    end
  end
end

function events.world_render(delta)
  if day.active then
    local flooredPos = clientPos:floor()
    local time = (TIME + delta) / 100
    for k,pos in pairs(fallingSnowDatabase) do
      for i,j in pairs(groundSnowDatabase) do
        local snowID = vec(flooredPos.x + pos.x, flooredPos.z + pos.y)
        local jVal = j[tostring(snowID)]
        if jVal then
          local floorSnow = jVal
          local fallingSnow = customRain[k]
          local scale = fallingSnow:getScale().y
          local vel = floorSnow.snowVel
          fallingSnow:setUVMatrix(matrices.scale3(1,5*scale,1):translate(time*vel.x,time*vel.y))
        end
      end
    end
  end
end

local facing_directions = {"north","east","south","west"}
-- does checking for so many blocks add a lot of instructions on reload? Yes. Do I care? No. Polish is nice ok ;w;
local denyList = {"head","fence","wall","door","pane","bars","chain","candle","pot","pickle","dragon","bamboo","lily","drip","lantern"}
local function reloadSnow(skull)
  local snow_part = skull.data.snowfall.snow
  local snow_template = skull.data.snowfall.templates.snow

  groundSnowDatabase[tostring(skull.pos)] = {}
  for k,v in pairs(skull.data.snowfall.snow:getChildren()) do
    snow_part:removeChild(v)
  end

  math.randomseed(skull.pos.x * 56093 + skull.pos.y * 49663 + skull.pos.z * 92791)

  for x = -8, 8 do
    for z = -8, 8 do
      if not (x == 0 and z == 0) and x^2+z^2 < 64 then
        for y = -20, 10 do
          y = -y
          local blockPos = skull.pos+vec(x,y,z)
          local blockstate = world.getBlockState(blockPos)
          local aboveBlockstate = world.getBlockState(blockPos+vec(0,1,0))
          local isDenyListed = false
          local isDenyListedAbove = false
          for k,v in pairs(denyList) do
            if string.find(blockstate.id,v) then
              isDenyListed = true
            end
            if string.find(aboveBlockstate.id,v) then
              isDenyListedAbove = true
            end
          end
          if (blockstate:hasCollision() and not (blockstate.id == "minecraft:light" or isDenyListed)) and (not aboveBlockstate:hasCollision() or aboveBlockstate.id == "minecraft:light" or isDenyListedAbove) then
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
                snowVel = vec(rng.float(-1, 1), rng.float(-1, -0.5)),
                snowScale = 1
              }
              local blockHeight = 0
              if blockstate:getCollisionShape()[1] then
                blockHeight = blockstate:getCollisionShape()[1][2].y
              end
              local part = snow_part:newPart(tostring(vec(x,z)))
              part:addChild(snow_template)
              part:setPos(x*16,(blockPos.y+blockHeight-skull.pos.y)*16,z*16)
              if blockHeight ~= 1 and blockstate.id:find("stairs") then
                local shape = blockstate:getProperties().shape
                if not string.find(shape,"outer") then
                  part:addChild(skull.data.snowfall.templates.stair:copy("stair"))
                  part.stair:setVisible(true)
                  for i = 0, 3 do
                    if facing_directions[i + 1] == blockstate:getProperties().facing then
                      part.stair:setRot(0,i*-90,0)
                    end
                  end
                end
                if string.find(shape, "outer") then
                  local mod = 0
                  if shape == "outer_right" then
                    mod = 90
                  end
                  part:addChild(skull.data.snowfall.templates.stair2:copy("stair2"))
                  part.stair2:setVisible(true)
                  for i = 0, 3 do
                    if facing_directions[i + 1] == blockstate:getProperties().facing then
                      part.stair2:setRot(0,i*-90-mod,0)
                    end
                  end
                end
                if string.find(shape,"inner") then
                  local mod = 0
                  if shape == "inner_left" then
                    mod = 90
                  end
                  part:addChild(skull.data.snowfall.templates.stair2:copy("stair2"))
                  part.stair2:setVisible(true)
                  for i = 0, 3 do
                    if facing_directions[i + 1] == blockstate:getProperties().facing then
                      part.stair2:setRot(0,i*-90+180-mod,0)
                    end
                  end
                end
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
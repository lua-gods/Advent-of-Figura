local Calendar = require("libraries.Calendar")

local day = Calendar:newDay("dvd")

local TV = models.dvd.TV

TV.DVD_VIDEO:setPrimaryRenderType('EMISSIVE'):setLight(15)
TV.colon_three:setPrimaryRenderType('EMISSIVE'):setLight(15)
TV.static:setPrimaryRenderType('EMISSIVE'):setLight(15)
TV.av_text:setPrimaryRenderType('EMISSIVE'):setLight(15)

local worn_part = day:addWornPart(TV)
worn_part.av_text:setVisible(false)
worn_part.static:setVisible(false)
worn_part:setPos(0,-1,1):setScale(0.78)
worn_part.colon_three:setVisible(true)
worn_part.DVD_VIDEO:setVisible(false)

local item_part = day:setItemPart(TV)
item_part.av_text:setVisible(true)
item_part.static:setVisible(true)
item_part.colon_three:setVisible(false)
item_part.DVD_VIDEO:setVisible(false)
item_part:setPos(0):setScale(1)

local function zigzag(value,range) -- credit to Roter Zwerg
    return math.acos(math.cos(value * math.pi / range)) / math.pi * range
end

---@param skull Skull
function day:init(skull)
    skull.data.tv = skull:addPart(TV)

    math.randomseed(skull.pos.x * 56093 + skull.pos.y * 49663 + skull.pos.z * 92791 + skull.rot)
    math.random(); math.random(); math.random()

    skull.data.seed = math.random() * 100000
end

function day:globalRender()
    item_part.static:setUV(math.random(0,48)/48,math.random(0,48)/48)
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)
    skull.data.tv.av_text:setVisible(false)
    skull.data.tv.static:setVisible(false)

    local dim = vec(12,11.1)

    skull.data.tv.DVD_VIDEO:setPos(-zigzag(world.getTime(delta)/10 + skull.data.seed / 200,dim.x - 2),-zigzag(world.getTime(delta)/10 + skull.data.seed / 200,dim.y - 2),0)
    :setColor(vectors.hsvToRGB(bit32.rrotate(math.floor(((world.getTime(delta)/10) + (skull.data.seed / 200)) / (dim.x - 2)) + math.floor(((world.getTime(delta)/10) + (skull.data.seed / 200)) / (dim.y - 2)),16) % 1050 / 1050, 0.5,1))
    skull.data.tv.colon_three:setVisible(false)
    skull.data.tv.DVD_VIDEO:setVisible(true)
end
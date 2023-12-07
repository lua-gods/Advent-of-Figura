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
    skull.data.tv.av_text:setVisible(false)
    skull.data.tv.colon_three:setVisible(false)

    math.randomseed(skull.pos.x * 56093 + skull.pos.y * 49663 + skull.pos.z * 92791 + skull.rot)
    math.random(); math.random(); math.random()

    skull.data.seed = math.random() * 100000
    skull.data.temp_static = rng.int(20,40)
end

---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)
    sounds["block.amethyst_block.place"]:pos(skull.pos):pitch(4):play()
    skull.data.temp_static = world.getTime() % 30 + 10
end

function events.WORLD_RENDER()
    item_part.static:setUV(math.random(0,48)/48,math.random(0,48)/48)
end

function day:tick(skull)
    if skull.data.temp_static > 0 then
        sounds["entity.creeper.hurt"]:pos(skull.pos):pitch(rng.float(2.5,4)):volume(0.5):play()
    end
    if world.getRainGradient() > 0.5 and world.getSkyLightLevel(skull.pos) == 15 and math.random() > 0.5 then
        skull.data.temp_static = rng.int(10,50)
        for _ = 1, 15 do
            particles["smoke"]:pos(skull.pos + rng.vec3() * 0.8 + vec(0.5,0,0.5)):spawn()
        end
    end
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)
    if skull.data.temp_static > 0 then
        skull.data.temp_static = skull.data.temp_static - 1
        skull.data.tv.static:setVisible(true):setUV(math.random(0,48)/48,math.random(0,48)/48)
        skull.data.tv.DVD_VIDEO:setVisible(false)
        return
    end
    skull.data.tv.static:setVisible(false)

    local dim = vec(12,11.1)

    skull.data.tv.DVD_VIDEO:setVisible(true)
    skull.data.tv.DVD_VIDEO:setPos(-zigzag(world.getTime(delta)/10 + skull.data.seed / 200,dim.x - 2),-zigzag(world.getTime(delta)/10 + skull.data.seed / 200,dim.y - 2),0)
    :setColor(vectors.hsvToRGB(bit32.rrotate(math.floor(((world.getTime(delta)/10) + (skull.data.seed / 200)) / (dim.x - 2)) + math.floor(((world.getTime(delta)/10) + (skull.data.seed / 200)) / (dim.y - 2)),16) % 1050 / 1050, 0.5,1))
end
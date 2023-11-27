local Calendar = require("libraries.Calendar")
local FireworkManager = require("libraries.fireworks.FireworkManager")
local variants = require("libraries.fireworks.variants")
local tween = require("libraries.GNTweenLib")
local day = Calendar:newDay("fireworks")

day:setItemPart(models.fireworks.Barrel)

function day:init(skull)
    skull.data.part = skull:addPart(models.fireworks.Barrel)
    skull.data.fireworks = FireworkManager.new()
    skull.data.offset = math.floor(skull.pos.x * 3 + skull.pos.z * 5 + skull.pos.y * 7) % 50
    skull.data.shift = vectors.vec3()
    skull.data.height = 0
    skull.data.squish = 1
end

---@param skull Skull
local function animation(skull)
    tween.tweenFunction(skull.data.shift,rng.vec3()*0.25,1,"outSine",function (x)
        skull.data.shift = x
        skull.data.part:setPos((skull.pos + vectors.vec3(x.x,skull.data.height,x.z)) * 16):setRot(0,x.y*180,0)
    end,nil)
    tween.tweenFunction(skull.data.height,0.5,0.2,"outQuart",function (x) -- jump
        skull.data.height = x --[[@as number]]
    end,function ()
        tween.tweenFunction(skull.data.height,0,0.2,"inSine",function (x) -- fall
            skull.data.height = x --[[@as number]]
        end,nil,"fireworks"..skull.id)
    end,"fireworks"..skull.id)
    tween.tweenFunction(skull.data.squish,0.9,0.05,"outSine",function (x) -- squish 
        skull.data.squish = x
        skull.data.part:setScale(1/x,x,1/x)
    end,function ()
        tween.tweenFunction(skull.data.squish,1.1,0.2,"inOutQuad",function (x) -- squish 
            skull.data.squish = x
            skull.data.part:setScale(1/x,x,1/x)
        end,function ()
            tween.tweenFunction(skull.data.squish,.75,0.3,"inOutQuad",function (x) -- squish 
                skull.data.squish = x
                skull.data.part:setScale(1/x,x,1/x)
            end,function ()
                tween.tweenFunction(skull.data.squish,1,0.2,"inOutQuad",function (x) -- squish 
                    skull.data.squish = x
                    skull.data.part:setScale(1/x,x,1/x)
                end,nil,"fireworks_s"..skull.id)
            end,"fireworks_s"..skull.id)
        end,"fireworks_s"..skull.id)
    end,"fireworks_s"..skull.id)
end

local function launch(skull)
    skull.data.part.lid:uvPixels(8,0)
    sounds["block.barrel.open"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(1.2):volume(0.05):play()
    for i = 1, 15 do
        particles["smoke"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):velocity(rng.vec3().x_z--[[@as Vector3]] * 0.2 + vec(0,0.01,0)):gravity():scale(0.7):lifetime(rng.float(15,30)):spawn()
    end
    animation(skull)
    delay(function()
        sounds["block.barrel.close"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(1.5):volume(0.05):play()
        delay(function()
            if not skull.data.part then return end
            skull.data.part.lid:uvPixels(0,0)
        end, 4)
    end, 15)
    
    skull.data.fireworks:spawn(skull.render_pos + vec(0.5, 0.5, 0.5), vec(0,1,0), variants[math.random(1, #variants)])
end

function day:tick(skull)
    if (TIME + skull.data.offset) % 50 == 0 then
        launch(skull)
    end
    skull.data.fireworks:tick()
end

function day:punch(skull, puncher)
    if puncher:getHeldItem().id:find("head") then return end
    launch(skull)
end

function day:exit(skull)
    if skull.data.fireworks then
        skull.data.fireworks:remove()
    end
end
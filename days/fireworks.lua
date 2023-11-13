local Calendar = require("libraries.Calendar")
local FireworkManager = require("libraries.fireworks.FireworkManager")
local tween = require("libraries.GNTweenLib")

local day = Calendar:newDay("fireworks", 24)

local function getHue()
    return vectors.hsvToRGB(math.random(), 1, 1)
end

local variants = {
    function(pos)
        local colour = getHue()
        local radius = rng.float(0.3,0.7)
        for _ = 1, 200 do
            colour = colour * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        for _ = 1, 20 do
            local vel = vec(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))/100
            particles["firework"]:pos(pos):velocity(vel * 0.2):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        particles["flash"]:pos(pos):color(colour)
    end,
    function(pos)
        local colour = getHue()
        local radius = math.random(130, 170)/100
        for _ = 1, 500 do
            colour = colour * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        for _ = 1, 20 do
            local vel = vec(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))/100
            particles["firework"]:pos(pos):velocity(vel * 0.2):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        particles["flash"]:pos(pos):color(colour)
    end,
    function(pos)
        local hue = math.random()
        local colour = vectors.hsvToRGB(hue, 1, 1)
        local radius = rng.float(0.3,0.7)
        for _ = 1, 100 do
            colour = colour * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        local colour2 = vectors.hsvToRGB(hue + 0.5, 1, 1)
        for _ = 1, 100 do
            colour2 = colour2 * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour2):spawn()
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour2):spawn()
        end
        for _ = 1, 20 do
            local vel = vec(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))/100
            particles["firework"]:pos(pos):velocity(vel * 0.2):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour2):spawn()
        end
        particles["flash"]:pos(pos):color(colour2)
    end,
    function(pos)
        local colour = getHue()
        local radius = rng.float(0.3,0.7)
        for _ = 1, 500 do
            colour = colour * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        for _ = 1, 20 do
            local vel = vec(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))/100
            particles["firework"]:pos(pos):velocity(vel * 0.2):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        particles["flash"]:pos(pos):color(colour)
    end,
    function(pos)
        local radius = rng.float(0.3,0.7)
        for _ = 1, 200 do
            local hue = math.random()
            local colour = vectors.hsvToRGB(hue, 0.5, 1) * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        particles["flash"]:pos(pos)
    end,
    function(pos)
        local hue = math.random()
        local colour = vectors.hsvToRGB(hue, 1, 1)
        local radius = rng.float(0.3,0.7)
        for _ = 1, 100 do
            colour = colour * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        local colour2 = vectors.hsvToRGB(hue + (math.random() * 0.1), 1, 1)
        for _ = 1, 100 do
            colour2 = colour2 * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour2):spawn()
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour2):spawn()
        end
        for _ = 1, 20 do
            local vel = vec(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))/100
            particles["firework"]:pos(pos):velocity(vel * 0.2):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour2):spawn()
        end
        particles["flash"]:pos(pos):color(colour2)
    end,
    function(pos)
        local colour = getHue()
        local radius = rng.float(0.3,0.7)
        for _ = 1, 400 do
            colour = colour * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        for _ = 1, 20 do
            local vel = vec(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))/100
            particles["firework"]:pos(pos):velocity(vel * 0.2):physics(false):scale(1):gravity(0.1):lifetime(math.random(30,150)):color(colour):spawn()
        end
        particles["flash"]:pos(pos):color(colour)
    end
}

function day:init(skull)
    skull.data.part = skull:addPart(models.fireworks.Barrel)
    skull.data.fireworks = FireworkManager.new()
    skull.data.offset = math.floor(skull.pos.x * 3 + skull.pos.z * 5 + skull.pos.y * 7) % 50
    skull.data.shift = vectors.vec3()
    skull.data.height = 0
end

function day:tick(skull)
    if (TIME + skull.data.offset) % 50 == 0 then
        skull.data.part.lid:uvPixels(8,0)
        sounds["block.barrel.open"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(1.2):volume(0.05):play()
        for i = 1, 15 do
            particles["smoke"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):velocity(rng.vec3().x_z--[[@as Vector3]] * 0.2 + vec(0,0.01,0)):gravity():scale(0.7):lifetime(rng.float(15,30)):spawn()
        end
        delay(function()
            sounds["block.barrel.close"]:pos(skull.render_pos + vec(0.5, 0.5, 0.5)):pitch(1.5):volume(0.05):play()
            delay(function()
                if not skull.data.part then return end
                skull.data.part.lid:uvPixels(0,0)
            end, 4)
        end, 15)
        tween.tweenFunction(skull.data.shift,vectors.vec3(math.random()-0.5,math.random()-0.5,(math.random()-0.5))*0.25,1,"outSine",function (x,t)
            skull.data.shift = x
            skull.data.part:setPos((skull.pos + vectors.vec3(x.x,skull.data.height,x.z)) * 16):setRot(0,x.y*180,0)
        end)
        tween.tweenFunction(skull.data.height,0.5,0.2,"outQuart",function (x)
            skull.data.height = x
        end,function ()
            tween.tweenFunction(skull.data.height,0,0.5,"outBounce",function (x)
                skull.data.height = x
            end)
        end)
        skull.data.fireworks:spawn(skull.render_pos + vec(0.5, 0.5, 0.5), vec(0,1,0), variants[math.random(1, #variants)])
    end
    skull.data.fireworks:tick()
end

function day:exit(skull)
    skull.data.fireworks:remove()
end
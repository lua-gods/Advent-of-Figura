local function getHue()
    return vectors.hsvToRGB(math.random(), 1, 1)
end

return {
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
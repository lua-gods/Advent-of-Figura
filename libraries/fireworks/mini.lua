local function getHue()
    return vectors.hsvToRGB(math.random(), 1, 1)
end

local SCALAR = 0.02
return {
    function(pos)
        local colour = getHue()
        local radius = rng.float(0.3,0.7)
        for _ = 1, 200 do
            colour = colour * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius * SCALAR
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1 * SCALAR):gravity(0.1 * SCALAR):lifetime(math.random(30,150)):color(colour):spawn()
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1 * SCALAR):gravity(0.1 * SCALAR):lifetime(math.random(30,150)):color(colour):spawn()
        end
        for _ = 1, 20 do
            local vel = vec(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))/100 * SCALAR
            particles["firework"]:pos(pos):velocity(vel * 0.2):physics(false):scale(1 * SCALAR):gravity(0.1 * SCALAR):lifetime(math.random(30,150)):color(colour):spawn()
        end
        particles["flash"]:pos(pos):color(colour)
    end,
    function(pos)
        local colour = getHue()
        local radius = math.random(98, 120)/100
        for _ = 1, 500 do
            colour = colour * (math.random(99, 100)/100)
            local vel = rng.vec3():normalize() * radius * SCALAR
            particles["firework"]:pos(pos):velocity(vel):physics(false):scale(1 * SCALAR):gravity(0.1 * SCALAR):lifetime(math.random(30,150)):color(colour):spawn()
            particles["end_rod"]:pos(pos):velocity(vel):physics(false):scale(1 * SCALAR):gravity(0.1 * SCALAR):lifetime(math.random(30,150)):color(colour):spawn()
        end
        for _ = 1, 20 do
            local vel = vec(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))/100 * SCALAR
            particles["firework"]:pos(pos):velocity(vel * 0.2):physics(false):scale(1 * SCALAR):gravity(0.1 * SCALAR):lifetime(math.random(30,150)):color(colour):spawn()
        end
        particles["flash"]:pos(pos):color(colour)
    end
}
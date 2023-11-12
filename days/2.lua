local Calendar = require("libraries.Calendar")
local day = Calendar:newDay(-(-({...})[2]))

local notes = {
    [0] = { 1.26, 1.498, 1, 0.5 },
    [15] = { 1.335, 1.682 },
    [20] = { 1.26, 1.498, 1 },
    [30] = { 1, 1.26, 0.749, 0.5 },
    [45] = { 0.841 },
    [50] = { 0.749 },
    [60] = { 1.26, 1.498, 1, 0.5 },
    [75] = { 1.335, 1.682 },
    [80] = { 1.26, 1.498, 1 },
    [90] = { 1, 1.26, 0.749, 0.5 },
    [105] = { 0.841 },
    [110] = { 0.749 },
    [120] = { 1.335, 2.245, 0.944, 0.749 },
    [140] = { 1.335, 2.245, 0.944 },
    [150] = { 1.335, 1.888, 1.122, 0.749 },
    [165] = { 1.26 },
    [170] = { 1.122 },
    [180] = { 1.26, 2, 1, 0.749 },
    [200] = { 1.26, 2, 1 },
    [210] = { 1.498, 1.26, 0.749, 0.5 },
    [225] = { 1.122 },
    [230] = { 1 },
    [240] = { 1.335, 1.682, 0.667, 1 },
    [260] = { 1.335, 1.682, 0.667, 0.841 },
    [270] = { 1.682, 2, 0.667, 1 },
    [285] = { 1.498, 1.888 },
    [290] = { 1.335, 1.682 },
    [300] = { 1.26, 1.498, 1, 0.63 },
    [315] = { 1.335, 1.682 },
    [320] = { 1.26, 1.498, 1 },
    [330] = { 1, 1.26, 0.749, 0.5 },
    [345] = { 0.841 },
    [350] = { 0.749 },
    [360] = { 1.335, 1.682, 0.667, 1 },
    [380] = { 1.335, 1.682, 0.667, 0.841 },
    [390] = { 1.682, 2, 0.667, 1 },
    [405] = { 1.498, 1.888 },
    [410] = { 1.335, 1.682 },
    [420] = { 1.26, 1.498, 1, 0.63 },
    [435] = { 1.335, 1.682 },
    [440] = { 1.26, 1.498, 1 },
    [450] = { 1, 1.26, 0.749, 0.5 },
    [465] = { 0.841 },
    [470] = { 0.749 },
    [480] = { 1.335, 2.245, 0.749, 0.944 },
    [500] = { 1.335, 2.245, 0.749, 0.944 },
    [510] = { 1.682, 2.67, 1.122, 0.561 },
    [525] = { 1.335, 2.245 },
    [530] = { 1.498, 1.888, 0.749 },
    [540] = { 1.26, 2, 1, 0.63 },
    [555] = { 0.667 },
    [560] = { 0.63 },
    [570] = { 1.498, 2.52, 1, 0.5 },
    [600] = { 1.26, 2, 0.63, 0.749 },
    [615] = { 1.26, 1.498 },
    [620] = { 1, 1.26, 0.5, 0.749 },
    [630] = { 0.944, 1.498, 0.375, 0.667 },
    [645] = { 0.841, 1.335 },
    [650] = { 0.944, 1.122, 0.375, 0.561 },
    [660] = { 0.749, 1, 0.5, 0.63 },
}

function day:init(skull)
    skull:addPart(models.jukebox)
    skull.data.time = 0
    skull.data.particles = {}
end

local function note(time, pos)
    if notes[time] then
        for i = 1, #notes[time] do
            sounds["block.note_block.harp"]:pos(pos + vec(0,0,1)):attenuation(1.5):volume(0.7):pitch(notes[time][i]):play()
        end
        return notes[time]
    end
end

local TWO_PI = math.pi * 2
local function noteColour(pitch)
    local red = math.max(0.0, math.sin(pitch * TWO_PI) * 0.65 + 0.35)
    local green = math.max(0.0, math.sin((pitch + (1/3)) * TWO_PI) * 0.65 + 0.35)
    local blue = math.max(0.0, math.sin((pitch + (2/3)) * TWO_PI) * 0.65 + 0.35)
    return red, green, blue
end

function day:tick(skull)
    local pitches = note(skull.data.time, skull.pos + vec(0.5, 0.5, 0.5))
    if pitches then
        for i = 1, #pitches do
            local lifetime = rng.float(20, 40)
            skull.data.particles[#skull.data.particles+1] = {
                particle = particles["note"]:pos(skull.pos + vec(0.5, 0.5, 0.5)):velocity(rng.vec3():normalize() * 0.1 + vec(0,0.2,0)):scale(0.5):lifetime(lifetime):color(noteColour(pitches[i])):spawn(),
                lifetime = lifetime,
                max_lifetime = lifetime
            }
        end
    end

    for i = #skull.data.particles, 1, -1 do
        local particle = skull.data.particles[i]
        particle.lifetime = particle.lifetime - 1
        particle.particle:scale(particle.lifetime / particle.max_lifetime)
        if particle.lifetime <= 0 then
            particle.particle:remove()
            table.remove(skull.data.particles, i)
        end
    end

    skull.data.time = skull.data.time + 1
    if skull.data.time >= 700 then
        skull.data.time = 0
    end
end

function day:exit(skull)
    for i = #skull.data.particles, 1, -1 do
        skull.data.particles[i].particle:remove()
    end
end
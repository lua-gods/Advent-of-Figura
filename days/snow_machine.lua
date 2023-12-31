local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("snow_machine")

---@param skull Skull
function day:init(skull)
    skull.data.particles = {}
end

---@param skull Skull
function day:tick(skull)
    for i = 1, 10 do
        local pos = skull.render_pos + vec(0.5 + rng.float(-0.5, 0.5), 0.5, 0.5 + rng.float(-0.5, 0.5))
        local vel = vec(rng.float(-0.1, 0.1), rng.float(0.8, 1), rng.float(-0.1, 0.1))
        skull.data.particles[#skull.data.particles+1] = particles["spit"]:pos(pos):velocity(vel):physics(true):spawn()
    end
    for i = #skull.data.particles, 1, -1 do
        local particle = skull.data.particles[i]
        if not particle:isAlive() then
            table.remove(skull.data.particles, i)
        end
    end
end

---@param skull Skull
function day:punch(skull)

end

---@param skull Skull
---@param delta number
function day:render(skull, delta)

end

---@param skull Skull
function day:exit(skull)

end
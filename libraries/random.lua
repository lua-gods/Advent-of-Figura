local rng = {}

---@return Vector3 (-0.5, -0.5, -0.5) to (0.5, 0.5, 0.5)
function rng.vec3()
    return vec(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
end

---@param min number
---@param max number
---@return number
function rng.float(min, max)
    return math.random() * (max - min) + min
end

_G.rng = rng

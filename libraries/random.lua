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

---@param ... number m, n
---@return integer
function rng.int(...)
    return math.floor(math.random(...))
end

---@return boolean
function rng.bool()
    return math.random() > 0.5
end

---@param from number
---@param to number
---@param step number
function rng.step(from, to, step)
    return math.floor((math.random() * (to - from) + from) / step) * step
end

---@param ... table|...
---@return any
function rng.of(...)
    return type((...)) == "table" and (...)[rng.int(#(...))] or rng.of({...})
end

_G.rng = rng

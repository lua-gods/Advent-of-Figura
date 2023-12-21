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

---@generic T
---@param ... T[]
---@return T, integer index
function rng.of(...)
    local i = rng.int(#(...))
    return type((...)) ~= "table" and rng.of({...}) or (...)[i], i
end

---@param val number|Vector3|string
function rng.seed(val)
    local seed
        =  type(val) == "number" and val
        or type(val) == "Vector3" and val.x * 73856093 + val.y * 19349669 + val.z * 83492791
        or type(val) == "string" and string.byte(val, 1)
        or error("Invalid seed type")
    math.randomseed(seed)
    math.random(); math.random(); math.random()
end

_G.rng = rng
---@alias keyframe { timestamp: number, data: Vector3, int: Animation.loopMode, bl: Vector3?, br: Vector3?, blt: Vector3?, brt: Vector3? }
---@type table<string, number>
local anim_map = {}
---@type table<string, table>
local anims = avatar:getNBT().animations
for i = 1, #anims do
    local anim = anims[i]
    anim_map[anim.name] = i - 1
end

---@type table<string, string>
local anim_modes = {}
---@type table<string, number>
local anim_lengths = {}
for i = 1, #anims do
    local anim = anims[i]
    anim_lengths[anim.name] = anim.len
    anim_modes[anim.name] = anim.loop or "once"
end

---@type table<string, table>
local structured_anims = {}
local function recurse(nbt, path)
    for i = 1, #nbt do
        local child = nbt[i]
        if child.anim then
            for j = 1, #child.anim do
                local anim = child.anim[j]
                structured_anims[anim.id] = structured_anims[anim.id] or {
                    len = anim.len,
                }
                structured_anims[anim.id][#structured_anims[anim.id] + 1] = {
                    path = path .. "." .. child.name,
                    data = anim.data,
                }
            end
        end
        if child.chld then
            recurse(child.chld, path .. "." .. child.name)
        end
    end
end
recurse(avatar:getNBT().models.chld, "models")

---@param base_part ModelPart
---@param path string
---@return ModelPart
local function findPart(base_part, path)
    local part = base_part
    for segment in path:gmatch("[^_]+") do
        part = part[segment]
        if not part then break end
    end
    return part
end

---@param anim table
---@param base_part ModelPart
---@return table<ModelPart, table<string, keyframe[]>>
local function getKeyframes(anim, base_part)
    local structured_keyframes = {}

    for i = 1, #anim do
        local cube = anim[i]
        local data = cube.data

        for transform_type, frames in next, data do
            for j = 1, #frames do
                local frame = frames[j]
                local time = frame.time
                local part = findPart(base_part, cube.path:gsub("^models%.[^%.]+%.", ""):gsub("%.", "_"))

                structured_keyframes[part] = structured_keyframes[part] or {}
                local part_keyframes = structured_keyframes[part][transform_type] or {}
                part_keyframes[#part_keyframes+1] = {
                    timestamp = time,
                    data = vec(table.unpack(frame.pre)),
                    int = frame.int,
                    bl = frame.bl and vec(table.unpack(frame.bl)),
                    br = frame.br and vec(table.unpack(frame.br)),
                    blt = frame.blt and vec(table.unpack(frame.blt)),
                    brt = frame.brt and vec(table.unpack(frame.brt)),
                }

                structured_keyframes[part][transform_type] = part_keyframes
            end
        end
    end

    for _, transforms in next, structured_keyframes do
        for _, frames in next, transforms do
            table.sort(frames, function(a, b)
                return a.timestamp < b.timestamp
            end)
        end
    end

    return structured_keyframes
end

---@class Anim
---@field private base_part ModelPart
---@field private structured_keyframes table<ModelPart, table<string, keyframe[]>>
---@field private length number
---@field private start_time number
---@field mode Animation.loopMode
---@field playing boolean
---@field time number
---@field id string
local Anim = {}
Anim.__index = Anim

---@param base_part ModelPart
---@param name string # the animation name minus the parent model ("animations.model.example" --> "example")
---@return Anim
function Anim.new(base_part, name)
    local self = setmetatable({}, Anim)
    self.base_part = base_part
    self.structured_keyframes = getKeyframes(structured_anims[anim_map[name]], base_part)
    self.mode = anim_modes[name]
    self.length = anim_lengths[name]
    self.start_time = client.getSystemTime() / 1000
    self.time = 0
    self.playing = false
    self.id = tostring(math.random())
    return self
end

function Anim:play()
    if self.playing then return end
    self.playing = true

    events.WORLD_RENDER:register(function()
        self:render()
    end, "anim_render_" .. self.id)
end

---@param frames keyframe[]
---@param time number
local function findFrames(frames, time)
    local n = #frames

    if time <= frames[1].timestamp then
        return frames[1], frames[1], frames[1], frames[1]
    end

    if time >= frames[n].timestamp then
        return frames[n], frames[n], frames[n], frames[n]
    end

    for i = 1, n - 1 do
        if frames[i].timestamp <= time and time < frames[i + 1].timestamp then
            local p0 = (i > 1) and frames[i - 1] or frames[i]
            local p1 = frames[i]
            local p2 = frames[i + 1]
            local p3 = (i < n - 1) and frames[i + 2] or frames[i + 1]
            return p0, p1, p2, p3
        end
    end
end

---@private
function Anim:render()
    local time = (client.getSystemTime() / 1000) - self.start_time

    if self.mode == "loop" then
        time = time % self.length
    elseif self.mode == "hold" then
        if time > self.length then
            time = self.length
        end
    elseif self.mode == "once" then
        if time > self.length then
            self:stop()
            return
        end
    end

    for part, transforms in next, self.structured_keyframes do
        for transform_type, frames in next, transforms do
            local p0, p1, p2, p3 = findFrames(frames, time)
            if p1 and p2 then
                local t = (p1.timestamp == p2.timestamp) and 0 or (time - p1.timestamp) / (p2.timestamp - p1.timestamp)
                self:applyTransformation(part, transform_type, p0, p1, p2, p3, t)
            end
        end
    end

    self.time = time
end

---@param p0 number
---@param p1 number
---@param p2 number
---@param p3 number
---@param t number
---@return number
local function catmullRom(p0, p1, p2, p3, t)
    local t2 = t * t
    local t3 = t2 * t
    return ((p1 * 2) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3 * p1 - 3 * p2 + p3) * t3) * 0.5
end

---@param p0 Vector3
---@param p1 Vector3
---@param p2 Vector3
---@param p3 Vector3
---@param t number
---@return Vector3
local function catmullRomInterpolate(p0, p1, p2, p3, t)
    return vec(
        catmullRom(p0.x, p1.x, p2.x, p3.x, t),
        catmullRom(p0.y, p1.y, p2.y, p3.y, t),
        catmullRom(p0.z, p1.z, p2.z, p3.z, t)
    )
end

---@param p0 number
---@param c0 number
---@param c1 number
---@param p1 number
---@param t number
---@return number
local function cubicBezier(p0, c0, c1, p1, t)
    local u = 1 - t
    local tt = t * t
    local uu = u * u
    local uuu = uu * u
    local ttt = tt * t
    local p = uuu * p0
    p = p + 3 * uu * t * c0
    p = p + 3 * u * tt * c1
    p = p + ttt * p1
    return p
end

---@param p0 Vector3
---@param c0 Vector3
---@param c1 Vector3
---@param p1 Vector3
---@param t number
---@return Vector3
local function bezierInterpolate(p0, c0, c1, p1, t)
    if not c0 then c0 = p0 end
    if not c1 then c1 = p1 end
    return vec(
        cubicBezier(p0.x, c0.x, c1.x, p1.x, t),
        cubicBezier(p0.y, c0.y, c1.y, p1.y, t),
        cubicBezier(p0.z, c0.z, c1.z, p1.z, t)
    )
end

---@private
---@param part ModelPart
---@param transform_type string
---@param p0 keyframe
---@param p1 keyframe
---@param p2 keyframe
---@param p3 keyframe
---@param t number
function Anim:applyTransformation(part, transform_type, p0, p1, p2, p3, t)
    local data
    if p1.int == "catmullrom" then
        data = catmullRomInterpolate(p0.data, p1.data, p2.data, p3.data, t)
    elseif p1.int == "bezier" then
        data = bezierInterpolate(p1.data, p1.br, p2.bl, p2.data, t)
    elseif p1.int == "step" then
        data = p1.data
    else
        data = math.lerp(p1.data, p2.data, t)
    end

    if transform_type == "rot" then
        part:rot(data * vec(-1, -1, 1))
    elseif transform_type == "pos" then
        part:pos(data * vec(-1, 1, 1))
    elseif transform_type == "scl" then
        part:scale(data)
    end
end

function Anim:stop()
    if not self.playing then return end
    self.playing = false

    events.WORLD_RENDER:remove("anim_render_" .. self.id)

    for part, transforms in next, self.structured_keyframes do
        for transform_type in next, transforms do
            part[transform_type == "scl" and "scale" or transform_type](part)
        end
    end
end

return Anim
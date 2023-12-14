---@class LSH
---@field buckets integer
---@field dimensions integer
---@field tables table[]
local LSH = {}
LSH.__index = LSH

---@param buckets integer buckets per dimension
---@param dimensions integer
---@return LSH
function LSH.new(buckets, dimensions)
    local self = setmetatable({}, LSH)
    self.buckets = buckets
    self.dimensions = dimensions
    self.tables = {}
    for i = 1, self.dimensions do
        self.tables[i] = {}
        for j = 1, self.buckets do
            self.tables[i][j] = {}
        end
    end
    return self
end

---@param pos Vector3
---@return integer[]
function LSH:hashFunc(pos)
    local hash = {}
    for i = 1, self.dimensions do
        hash[i] = math.floor(pos[i] * self.buckets) % self.buckets + 1
    end
    return hash
end

---@param boid Boid
function LSH:addBoid(boid)
    local hash = self:hashFunc(boid.pos)
    for i = 1, self.dimensions do
        self.tables[i][hash[i]][#self.tables[i][hash[i]]+1] = boid
    end
end

---@param pos Vector3
---@return Boid[]
function LSH:getNeighbors(pos)
    local hash = self:hashFunc(pos)
    local seen = {}
    local neighbors = {}
    for i = 1, self.dimensions do
        for j = 1, #self.tables[i][hash[i]] do
            local boid = self.tables[i][hash[i]][j]
            if not seen[boid] then
                seen[boid] = true
                neighbors[#neighbors+1] = boid
            end
        end
    end
    return neighbors
end

function LSH:clear()
    for i = 1, self.dimensions do
        for j = 1, self.buckets do
            self.tables[i][j] = {}
        end
    end
end

return LSH
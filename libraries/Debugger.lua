---@class Debugger
---@field private data table<string, string>
local Debugger = {}
Debugger.__index = Debugger

function Debugger.new()
    local self = setmetatable({}, Debugger)
    self.data = {}
    return self
end

function Debugger:expose(name, value)
    self.data[name] = value
end

function Debugger:getAll()
    local out = {}
    for name, value in next, self.data do
        out[#out + 1] = ("§7%s: §r§%s"):format(name, value)
    end
    return out
end

function Debugger:hasData()
    return next(self.data) ~= nil
end

return Debugger
---@class EventChannel
---@field events table<string, table<number, function>>
local EventChannel = {}
EventChannel.__index = EventChannel

---@return EventChannel
function EventChannel.new()
    local self = setmetatable({}, EventChannel)
    self.events = {}
    return self
end

---@param event string
---@param func fun(...): any?
function EventChannel:on(event, func)
    if not self.events[event] then
        self.events[event] = {}
    end
    self.events[event][#self.events[event] + 1] = func
    return func
end

---@param event string
---@param func fun(...): any?
function EventChannel:once(event, func)
    local function once(...)
        self:remove(event, once)
        return func(...)
    end
    self:on(event, once)
    return func
end

---@param event string
---@vararg any
---@return any? result
function EventChannel:emit(event, ...)
    if not self.events[event] then return end
    local i = 1
    while i <= #self.events[event] do
        local handler = self.events[event][i]
        local result = handler(...)
        if result then return result end
        if self.events[event][i] == handler then
            i = i + 1
        end
    end
end

---@param event string
---@param func function
function EventChannel:remove(event, func)
    if not self.events[event] then return end
    for i = 1, #self.events[event] do
        if self.events[event][i] == func then
            table.remove(self.events[event], i)
            break
        end
    end
end

_G.event = EventChannel.new()

return EventChannel
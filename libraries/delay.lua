---@param func fun()
---@param time number|fun():boolean
---@vararg any
local function delay(func, time, ...)
    local timer = 0
    local id = "delay-" .. tostring(func) .. math.random()
    local args = {...}
    events.WORLD_TICK:register(function ()
        timer = timer + 1
        if type(time) == "function" then
            if time() then
                func(table.unpack(args))
                events.WORLD_TICK:remove(id)
            end
        elseif timer >= time then
            func(table.unpack(args))
            events.WORLD_TICK:remove(id)
        end
    end, id)
end

_G.delay = delay
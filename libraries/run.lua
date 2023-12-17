---Run the function every tick for `time` ticks, or if `time` is a function, until it returns true.
---@param func fun(i: integer)
---@param time number|fun(i: integer): boolean
---@param done? fun(i: integer)
local function run(func, time, done)
    local id = "run-" .. tostring(func) .. client.getSystemTime()
    local runner = nil
    local function finish(i)
        events.WORLD_TICK:remove(id)
        if done then
            done(i)
        end
    end
    if type(time) == "function" then
        function runner(i)
            (time(i) and finish or func)(i)
        end
    else
        local i = 0
        function runner()
            (i >= time and finish or func)(i)
            i = i + 1
        end
    end
    events.WORLD_TICK:register(runner, id)
end

_G.run = run
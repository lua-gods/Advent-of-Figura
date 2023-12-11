local format = {}

---@param seconds number
---@return string formatted
---@nodiscard
function format.short_time(seconds)
    local second = seconds % 60
    local minute = math.floor(seconds / 60) % 60
    local hour = math.floor(seconds / 3600) % 24
    local day = math.floor(seconds / 86400)

    local str = ""
    if day > 0 then
        str = str .. string.format("%dd ", day)
    end
    if hour > 0 then
        str = str .. string.format("%dh ", hour)
    end
    if minute > 0 then
        str = str .. string.format("%dm ", minute)
    end
    if second > 0 then
        str = str .. string.format("%ds", second)
    end

    return str
end

_G.format = format
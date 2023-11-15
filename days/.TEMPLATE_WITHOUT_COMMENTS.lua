local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("", -1)

---@param skull Skull
function day:init(skull)

end

---@param skull Skull
function day:tick(skull)

end

---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)

end

---@param skull Skull
---@param delta number
function day:render(skull, delta)

end

---@param skull Skull
function day:exit(skull)

end

---@param skulls Skull[]
function day:globalTick(skulls)

end

---@param skulls Skull[]
function day:globalInit(skulls)

end

---@param skulls Skull[]
function day:globalExit(skulls)

end

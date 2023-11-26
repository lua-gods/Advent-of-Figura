local Calendar = require("libraries.Calendar")
local FireworkManager = require("libraries.fireworks.FireworkManager")
local MiniFirework = require("libraries.fireworks.MiniFirework")
local mini = require("libraries.fireworks.mini")

local day = Calendar:newDay("badge")

---@param skull Skull
function day:init(skull)
    local part = skull:addPart(models:newPart("text_anchor"))
    skull.data.task = part:newText("Badge")
    :scale(0.1)
    :pos(0,16,0)
    :alignment("CENTER")
    :shadow(true)
    :background(true)
    :text("Thank you for participating in §lAdvent of Figura 2023!§r\nWe hope you've enjoyed the past few weeks of content.\nYou'll get a special badge next to your name in Backend V3.")
    skull.data.manager = FireworkManager.new(MiniFirework.new)
end

function day:render(skull, delta)
    skull.data.task:rot(utils.dirToAngle(((skull.pos + vec(0.5,1,0.5)) - client:getCameraPos()):normalize()) + vec(0, skull.rot, 0))
end

function day:tick(skull)
    if world.getTime() % 40 == 0 then
        skull.data.manager:spawn(skull.render_pos + vec(0.5, 0.5, 0.5), vec(0,1,0), mini[math.random(1, #mini)])
    end
    skull.data.manager:tick()
end
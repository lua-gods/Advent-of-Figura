local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("carols")

day:setItemPart(models.model.item):setColor(1,1,0)

local function build(text, order)
    local words = utils.split(text, ' ')
    local chain = {}

    for i = 1, #words - order do
        local key = table.concat({ table.unpack(words, i, i + order - 1) }, ' ')
        local next_word = words[i + order]

        if not chain[key] then
            chain[key] = {}
        end

        chain[key][#chain[key] + 1] = next_word
    end

    return chain
end

local function generate(chain, length)
    local key = rng.of(utils.keys(chain))
    local words = utils.split(key, ' ')
    local text = key

    for _ = 1, length do
        local choices = chain[key]
        if not choices or #choices == 0 then break end
        local next_word = rng.of(choices)
        words[#words + 1] = next_word
        table.remove(words, 1)
        key = table.concat(words, ' ')
        text = text .. ' ' .. next_word
    end

    return text
end

local source_text = require(.....".carols.all")

local order = 1
local length = 50

local chain = build(source_text, order)

local function carol()
    return generate(chain, length)
end

---@param skull Skull
function day:init(skull)
    local part = skull:addPart(models:newPart("text_anchor"))
    skull.data.task = part:newText("Badge")
        :scale(0.1)
        :alignment("CENTER")
        :shadow(true)
        :background(true)
        :light(15,15)
        :width(200)
        :wrap(true)
    rng.seed(skull.pos)
    skull.data.carol = "§e" .. carol():gsub(".", "§k%1")
    skull.data.time = 0
    skull.data.seedstep = 0
    _, skull.data.current_lines = skull.data.carol:gsub("\n", "")
end

function day:render(skull, delta)
    local time = skull.data.time + delta
    skull.data.task
        :text(skull.data.carol)
        :matrix(matrices.mat4()
        :translate(vec(0, 0.8, 0) * time * 0.35)
        :rotate((utils.dirToAngle(((skull.pos + vec(0.5,1.5,0.5)) - client:getCameraPos()):normalize())._y_ + vec(45, skull.rot, 0))--[[@as Vector3]])
        :scale(0.2,0.2,0.2))
    local lines_used = 0.8 * time * 0.35
    local _, lines = skull.data.carol:gsub("\n", "")
    lines = lines * 11.10
    if lines_used > lines then
        skull.data.seedstep = skull.data.seedstep + 1
        rng.seed(skull.pos + vec(0,0,skull.data.seedstep))
        skull.data.carol = skull.data.carol .. "\n§k" .. carol():gsub(".", "§k%1")
        _, skull.data.current_lines = skull.data.carol:gsub("\n", "")
    end
end

---@param skull Skull
function day:tick(skull)
    skull.data.time = skull.data.time + 1
    skull.data.carol = skull.data.carol:gsub("§k", "", 1)
end
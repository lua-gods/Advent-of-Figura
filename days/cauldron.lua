local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("cauldron")

day:setItemPart(models:newPart("cauldron_item")):newBlock("item"):block("cauldron"):scale(0.55):pos(-9,-3,0)

local function transform(a, b, ...)
    if b == nil then
        return a
    end

    return transform(b * a, ...)
end

---@class KDNode
---@field left KDNode|KDLeaf
---@field right KDNode|KDLeaf
---@field division number
---@field private ydivision boolean
---@field private update fun(KDNode, any, any)
---@field dispose fun(KDNode, any, any)
---@field isLeaf false
local KDNode = {}
KDNode.__index = KDNode
KDNode.isLeaf = false

function KDNode.new(ydivide, update, dispose)
    local self = setmetatable({}, KDNode)
    self.left = nil
    self.right = nil
    self.ydivision = ydivide
    self.division = 0.5
    self.update = update or function() end
    self.dispose = dispose or function() end
    return self
end

function KDNode:updateAsRoot()
    return self:updateBounds(vec(0, 0), vec(1, 1))
end

function KDNode:updateBounds(lowXY, highXY)
    self.update(self, lowXY, highXY)
    if self.ydivision then
        self.left:updateBounds(lowXY, highXY.x_ + math.lerp(lowXY._y, highXY._y, self.division))
        self.right:updateBounds(lowXY.x_ + math.lerp(lowXY._y, highXY._y, self.division), highXY)
    else
        self.left:updateBounds(lowXY, highXY._y + math.lerp(lowXY.x_, highXY.x_, self.division))
        self.right:updateBounds(lowXY._y + math.lerp(lowXY.x_, highXY.x_, self.division), highXY)
    end
    return self
end


---@class KDLeaf
---@field private update fun(KDNode, any, any)
---@field dispose fun(KDNode, any, any)
---@field isLeaf true
local KDLeaf = {}
KDLeaf.__index = KDLeaf
KDLeaf.isLeaf = true

function KDLeaf.new(update, dispose)
    local self = setmetatable({}, KDLeaf)
    self.update = update or function() end
    self.dispose = dispose or function() end
    return self
end

function KDLeaf:updateBounds(lowXY, highXY)
    self.update(self, lowXY, highXY)
    return self
end

local function generateKDTree(predicate, nodeGenerator, leafGenerator, depth)
    if depth == nil then
        depth = 1
    end
    local tree = KDNode.new(depth % 2 == 0, nodeGenerator())
    if predicate(depth) then
        tree.left = generateKDTree(predicate, nodeGenerator, leafGenerator, depth + 1)
        tree.right = generateKDTree(predicate, nodeGenerator, leafGenerator, depth + 1)
    else
        tree.left = KDLeaf.new(leafGenerator())
        tree.right = KDLeaf.new(leafGenerator())
    end
    return tree
end

local heatSources = {
    ["minecraft:fire"] = 1,
    ["minecraft:magma"] = 2,
    ["minecraft:lava"] = 5,
    ["minecraft:ice"] = -1,
    ["minecraft:blue_ice"] = -5,
    ["minecraft:packed_ice"] = -2,
    ["minecraft:dragon_egg"] = -0.5,
    ["minecraft:endstone"] = -0.2,
    ["minecraft:water"] = -0.1
}

local function calculateHeat(valuePerBlock)
    local heatThrust = 0
    for i = 1, 5 do
        heatThrust = heatThrust + valuePerBlock / i
    end
    return heatThrust
end

---@param skull Skull
function day:init(skull)
    local posHash = skull.pos.x * 73856093 + skull.pos.y * 19349669 + skull.pos.z * 83492791
    skull.debugger:expose("seed", posHash)
    math.randomseed(posHash)

    local maxHeat = -9999
    local minHeat = 9999

    for _, i in pairs(heatSources) do
        if i > maxHeat then
            maxHeat = i
        end
        if i < minHeat then
            minHeat = i
        end
    end

    local idealHeatCenter = math.lerp(calculateHeat(minHeat) * 10, calculateHeat(maxHeat) * 10, math.random())

    local idealMixCenter = math.random() * 25
    if idealHeatCenter < 0 then
        idealMixCenter = idealMixCenter / 2
    end
    if math.random() > 0.9 then
        idealMixCenter = idealMixCenter * 2
    end

    skull.debugger:expose("ideal_heat", idealHeatCenter)
    skull.debugger:expose("ideal_mix", idealMixCenter)

    local finishing = 0

    local mixStress = 0
    local heatStress = 0

    local base = models:newPart("", "None")
    models:removeChild(base)
    base = skull:addPart(base)

    local root = models:newPart("", "None")
    base:addChild(root)

    root:setMatrix(
        transform(
            matrices.translate4(-8,0,-8),
            matrices.scale4(0.5, 0.5, 0.5)
        )
    )

    root:newBlock("e")
    :block("minecraft:cauldron")

    local statLabel = root:newText("o")
    statLabel:setPos(16, 15, 0)
    statLabel:setScale(0.2, 0.2, 0.2)

    local hand = root:newText("po")
    hand:setPos(16, 5, 0)
    hand:setScale(0.07, 0.07, 0.07)

    local iceRoot = models:newPart("", "None")
    root:addChild(iceRoot)

    iceRoot:setMatrix(
        transform(
            matrices.translate4(-8, 0, -8),
            matrices.scale4(12 / 16, 1, 12 / 16),
            matrices.translate4(8, 14, 8)
        )
    )

    local waterSprite = root:newSprite("p")
    local atlas = client.getAtlas("minecraft:textures/atlas/blocks.png")
    local waterUV = atlas:getSpriteUV("minecraft:block/water_still")
    waterSprite:setTexture("minecraft:textures/atlas/blocks.png", atlas:getWidth(), atlas:getHeight())
    waterSprite:setRegion(16,16)--waterUV.z - waterUV.x, waterUV.w - waterUV.y)
    waterSprite:setUV(waterUV.xy)
    waterSprite:size(16,16)
    waterSprite:color(0, 0.2, 1)
    waterSprite:renderType("TRANSLUCENT_CULL")
    waterSprite:matrix(
        transform(
            matrices.xRotation4(90),
            matrices.translate4(16,13.9,16)
        )
    )


    local kdRoot = generateKDTree(function(depth) return depth < 6 end,
    function()
        local o = math.random() / 2 + 0.25
       return function(node)
        node.division = o
    end, function() end
    end, function()
            local id = "gen-" .. math.random()
            local task = iceRoot:newBlock(id)
            task:block("minecraft:ice")

            local eid = "gen-" .. math.random()
            local eggnogTask = iceRoot:newBlock(eid)
            eggnogTask:block("minecraft:yellow_wool")

            return function(_, lowXY, highXY)
                local offcenter = ((lowXY + highXY) / 2 - vec(0.5, 0.5)):length()
                local treshhold = (-0.75 + offcenter) * 10
                local visible = treshhold > heatStress
                task:visible(visible)
                local height = -(heatStress - treshhold) * math.max(0, 1 - finishing * 2)
                task:matrix(
                    transform(
                        matrices.translate4(-8, 0, -8),
                        matrices.scale4(math.min(1, height), 1, math.min(1, height)),
                        matrices.scale4(highXY.x - lowXY.x, math.min(height / 10, 10 / 16), highXY.y - lowXY.y),
                        matrices.translate4((lowXY.x_y + highXY.x_y) / 2 * 16),
                        matrices.translate4(0, -math.min(height / 10, 10 / 16) * 16, 0)
                    )
                )

                height = -(-0.75 + offcenter) * math.max(0, finishing - 0.5) * 10
                eggnogTask:matrix(
                    transform(
                        matrices.translate4(-8, 0, -8),
                        matrices.scale4(math.min(1, height), 1, math.min(1, height)),
                        matrices.scale4(highXY.x - lowXY.x, height / 5, highXY.y - lowXY.y),
                        matrices.translate4((lowXY.x_y + highXY.x_y) / 2 * 16 - vec(0, 3, 0))
                    )
                )
            end,
            function()
                iceRoot:removeTask(id)
                iceRoot:removeTask(eid)
            end
        end,
        1
    )

    skull.data.lifecycle = {
        tick = function()
            local heatThrust = 0

            for i = 1, 5 do
                local o = heatSources[world.getBlockState(skull.pos - vec(0, i, 0)).id]
                if o ~= nil then
                    heatThrust = heatThrust + o / i
                end
            end

            if math.abs(heatStress - idealHeatCenter) > 1 then
                hand:visible(true)
                hand:text("Maybe this thing needs " .. (heatThrust == 0 and "" or "more ") .. ((heatStress - idealHeatCenter) < 0 and "lava" or "ice") .. " under it")
            else
                hand:visible(false)
            end


            heatStress = heatStress * 0.999
            mixStress = mixStress * 0.99

            heatStress = heatStress + heatThrust / 50

            if math.random() < (heatStress - 50) / 100 then
                particles["dust 0.5 0.5 0.5 1"]:velocity(0, 0.03, 0):pos(skull.pos + vec(math.random() * 0.5 + 0.25, 0.5, math.random() * 0.5 + 0.25)):spawn()
            end

            if finishing < 1 then
                local goal = 2 - (math.abs(idealHeatCenter - heatStress) + math.abs(idealMixCenter - mixStress))
                finishing = math.min(1, math.max(finishing + goal / 2000, 0))

                if finishing == 1 then
                    for i = 1, 30 do
                        local color = vec(1, 0, 0)
                        if math.random() > 0.5 then
                            color = vec(0, 1, 0)
                        end
                        particles["firework"]
                        :velocity((math.random() - 0.5) / 2, math.random(), (math.random() - 0.5) / 2)
                        :pos(skull.pos + vec(0.5, 0.8, 0.5))
                        :color(color)
                        :lifetime(1000)
                        :spawn()
                    end
                end
            end

            if finishing == 1 then
                statLabel:text("eggnog!")
            else
                statLabel:text("ideal heat: " .. math.round(idealHeatCenter) .. "\nideal mixing: " ..  math.round(idealMixCenter) .. "\nheat: " ..  math.round(heatStress) .. "\nmixing: " ..  math.round(mixStress) .. "\ncompletion: " ..  (finishing))
            end


            local biome = world.getBiome(skull.pos)
            local waterColor = biome:getWaterColor()
            local heatedWaterColor = math.lerp(waterColor, vec(1, 0, 0), math.max(0, heatStress) / 100)
            local finishedWaterColor = math.lerp(heatedWaterColor, vectors.hexToRGB("FDEA9F"), math.min(1, finishing * 2))
            
            waterSprite:color(finishedWaterColor)


        end,
        punch = function(puncher)
            if heatStress < 0 then
                heatStress = heatStress + 0.01
                mixStress = mixStress + 0.5
            else
                mixStress = mixStress + 1
            end
        end,
        render = function(delta)
            kdRoot:updateAsRoot()
            root:setMatrix(
                transform(
                    matrices.translate4(-8,0,-8),
                    matrices.yRotation4(finishing == 1 and 0 or math.pow(finishing, 10) * math.cos(world.getTime()) * 2),
                    matrices.scale4(0.5, 0.5, 0.5)
                )
            )
        end,
        dispose = function()

        end
    }
end

---@param skull Skull
function day:tick(skull)
    skull.data.lifecycle.tick()
end

---@param skull Skull
---@param puncher Player
function day:punch(skull,puncher)
    skull.data.lifecycle.punch(puncher)
end

---@param skull Skull
---@param delta number
function day:render(skull, delta)
    skull.data.lifecycle.render(delta)
end

---@param skull Skull
function day:exit(skull)
    skull.data.lifecycle.dispose()
end
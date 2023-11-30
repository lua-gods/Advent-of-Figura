local Calendar = require("libraries.Calendar")
local day = Calendar:newDay("tree")

local skullManager = require("libraries.SkullManager")


---@param skull Skull
function day:init(skull)
    models.tree.leaf:setColor(world.getBiome(skull.pos):getFoliageColor())
    skull.data.part = skull:addPart(models.tree.log)
    skull.data.update = function (offset,recursive)
        -- update feller tree lovers
        skull.data.size = 0
        for i = -1, -10, -1 do -- get stack
            local pos = skull.pos:copy():add(0,i,0)
            if skullManager:has(pos) then
                local skata = skullManager:get(pos)
                if recursive then
                if skata.data and skata.data.update then
                        skata.data.update(offset)
                    end
                end
                skull.data.size = -i
            else
                break
            end
        end

        for i = 1, 10, 1 do -- get stack size
            if not skullManager:has(skull.pos:copy():add(0,i,0)) then
                skull.data.stack = i + (offset or 0)
                skull.data.size = skull.data.size + i
                local e = skull.data.stack / 10 + 0.5
                skull.data.part:scale(e,1,e)
                break
            end
        end
        
        -- remove existing leaves
        for key, part in pairs(skull.data.leaves or {}) do
            part:getParent():removeChild(part)
        end
        -- generate leaves
        local size = skull.data.size
        local leaves = (skull.data.stack or 1) / 3 + 5
        skull.data.leaves = {}
        for i = 1, leaves, 1 do
            local s = skull.data.stack / (size + 1)
            local leaf = skull:addPart(models.tree.leaf)
            local mat = matrices.mat4()
            local leaf_size = s + 1 * (size * 0.1 + 0.1)
            mat
            :rotateZ(-90 + s * 67.5)
            :rotateY(((i + math.random())/leaves) * 360)
            :scale(leaf_size,math.max(leaf_size,1),leaf_size)
            :translate(skull.pos*16)
            :translate(0,20+math.random() * 5 + (s*s * 8),0)
            leaf:setMatrix(mat)
            skull.data.leaves[#skull.data.leaves+1] = leaf
        end
    end

    skull.data.update(0,true)
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
    skull.data.update(-skull.data.stack,true)
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

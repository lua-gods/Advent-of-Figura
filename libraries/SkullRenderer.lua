local world_base = models:newPart("skull_world_base"):setParentType("SKULL"):light(15,15)
local world_part = world_base:newPart("skull_world"):light(15,15)

local facing_rots = {
    north = 0,
    south = 8,
    east = 4,
    west = 12
}
local facing_offsets = {
    south = vec(0,-0.25,0.25),
    east = vec(0.25,-0.25,0),
    north = vec(0,-0.25,-0.25),
    west = vec(-0.25,-0.25,0)
}

local render_skull = false
function events.WORLD_RENDER()
    render_skull = true
end

local item = models.model.item:setParentType("SKULL")
function events.SKULL_RENDER(_, blockstate)
    if blockstate then
        item:visible(false)
        local pos = blockstate:getPos()
        if render_skull then
            render_skull = false
            if blockstate.id == "minecraft:player_head" then
                world_base:rot(0,blockstate.properties.rotation*22.5,0):visible(true)
                world_part:pos(-pos*16)
            elseif blockstate.id == "minecraft:player_wall_head" then
                world_base:rot(0,facing_rots[blockstate.properties.facing]*22.5,0):visible(true)
                world_part:pos((-pos + facing_offsets[blockstate.properties.facing])*16)
            end
        else
            world_base:visible(false)
        end
    else
        world_base:visible(false)
        item:visible(true)
    end
end

---@class SkullRenderer
---@field parts ModelPart[]
local SkullRenderer = {}
SkullRenderer.__index = SkullRenderer

function SkullRenderer.new()
    local self = setmetatable({}, SkullRenderer)
    self.parts = {}
    return self
end

---@param part ModelPart
function SkullRenderer:addPart(part)
    world_part:addChild(part)
    self.parts[#self.parts + 1] = part
end

function SkullRenderer:reset()
    for _, part in next, self.parts do
        world_part:removeChild(part)
    end
    self.parts = {}
end

return SkullRenderer
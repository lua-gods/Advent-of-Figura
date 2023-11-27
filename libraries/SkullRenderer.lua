local world_base = models:newPart("skull_world_base"):setParentType("SKULL")
local world_part = world_base:newPart("skull_world")

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
local fallback = 0
function events.WORLD_RENDER()
    render_skull = true
    fallback = fallback + 1
end

local ENTITY_OFFSET = vec(7,-19.5,7)
local PLAYER_SCALE = math.playerScale ^ 2
function events.SKULL_RENDER(delta, blockstate, itemstack, entity, context)
    if blockstate then
        fallback = 0
        if render_skull then
            render_skull = false
            local pos = blockstate:getPos()
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
    elseif entity and context == "HEAD" then
        if render_skull and fallback > 1 then
            render_skull = false
            world_base:visible(true)
            local rot = entity:getRot(delta)
            world_base:matrix(matrices.mat4():translate(-entity:getPos(delta) * 16):scale(PLAYER_SCALE, PLAYER_SCALE, PLAYER_SCALE):translate(ENTITY_OFFSET):rotate(0, rot.y + 180, 0):rotate(rot.x, 0, 0))
            world_part:pos()
        else
            world_base:visible(false)
        end
    else
        world_base:visible(false)
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
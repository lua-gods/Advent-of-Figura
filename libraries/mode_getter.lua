local base64 = require("libraries.base64")
local calendar = require("libraries.Calendar")

local mode_getter = {}

---@param data table?
local function getTextureValue(data)
    local owner = data and data.SkullOwner
    local properties = owner and owner.Properties
    local textures = properties and properties.textures
    return textures and textures[1] and textures[1].Value
end

---@param data table?
local function decode(data)
    local texture_value = base64.decode(getTextureValue(data):gsub(1, 128))
    return calendar:byName(texture_value)
end

---@param blockstate BlockState
---@return Day?
function mode_getter.fromBlock(blockstate)
    return decode(blockstate:getEntityData())
end

---@param itemstack ItemStack
---@return Day?
function mode_getter.fromItem(itemstack)
    return decode(itemstack:getTag())
end

return mode_getter
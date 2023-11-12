---@param model ModelPart
---@return ModelPart
local function deepCopy(model)
    local copy = model:copy(model:getName())
    for _, child in pairs(copy:getChildren()) do
        copy:removeChild(child):addChild(deepCopy(child)):parentType()
    end
    return copy
end

return deepCopy
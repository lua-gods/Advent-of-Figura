local function dir(directory)
    local files = listFiles(directory, true)
    for i = 1, #files do
        require(files[i])
    end
end

local immediate = {
    "core",
    "startup",
    "libraries",
    "days",
}

local entity_init = {
    "modules",
}

for i = 1, #immediate do
    dir(immediate[i])
end

function events.ENTITY_INIT()
    for i = 1, #entity_init do
        dir(entity_init[i])
    end
end
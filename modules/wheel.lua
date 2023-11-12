if not IS_HOST then return end

local base64 = require("libraries.base64")

local main_page = action_wheel:newPage()
action_wheel:setPage(main_page)

local function giveHead(name)
    local item = world.newItem("player_head" .. (toJson{
        SkullOwner = {
            Id = {
                client.uuidToIntArray(avatar:getUUID())
            },
            Properties = {
                textures = {
                    {
                        Value = base64.encode(name)
                    }
                }
            }
        },
        display = {
            Name = toJson{
                {
                    italic = false,
                    text = ""
                },
                (function()
                    local t = {}
                    for i = 1, #name do
                        t[#t+1] = {
                            text = name:sub(i,i),
                            color = "#" .. vectors.rgbToHex(vectors.hsvToRGB(((i - 1) / #name) * (1/3), 0.7, 1))
                        }
                    end
                    return table.unpack(t)
                end)()
            }
        }
    }):gsub('"Id":%[','"Id":[I;'))
    main_page:newAction():title(name):item(item):onLeftClick(function ()
        host:setSlot(player:getNbt().SelectedItemSlot, item)
        sounds["entity.item.pickup"]:pos(player:getPos()):play()
    end)
end

local n_actions = 0
for _, file in next, listFiles("days") do
    n_actions = n_actions + 1
    giveHead(file:gsub("days%.",""))
end

while n_actions % 8 ~= 0 do
    n_actions = n_actions + 1
    main_page:newAction():hoverColor(0,0,0)
end
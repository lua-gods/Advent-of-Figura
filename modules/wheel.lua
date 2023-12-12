if not IS_HOST then return end

local base64 = require("libraries.base64")

local main_page = action_wheel:newPage()
action_wheel:setPage(main_page)

local removed = {}
main_page:newAction():title("§cRemove nearby skulls\n§7(Right click to undo)§r"):item("tnt"):onLeftClick(function ()
    local i = 0
    events.SKULL_RENDER:register(function (delta, block, item, entity, ctx)
        if block then
            i = i + 1
            local pos = block:getPos()
            if (pos - client:getCameraPos()):length() > 12 then return end
            removed[#removed + 1] = { pos = pos, block = block:toStateString() }
            host:sendChatCommand("setblock " .. pos.x .. " " .. pos.y .. " " .. pos.z .. " air")
            for _ = 1, 20 do
                particles["smoke"]:pos(pos + vec(0.5,0,0.5) + rng.vec3() * 0.3):velocity(rng.vec3() * 0.2):scale(rng.float(0.4,0.8)):spawn()
            end
            if i < 5 then
                sounds["entity.illusioner.prepare_blindness"]:pos(pos):subtitle("Skull removed"):pitch(3):volume(1/i):attenuation(2):play()
            end
        end
    end, "remove_skulls")
    events.POST_WORLD_RENDER:register(function (delta)
        events.SKULL_RENDER:remove("remove_skulls")
        events.POST_WORLD_RENDER:remove("remove_skulls")
    end, "remove_skulls")
end):onRightClick(function ()
    for i = 1, #removed do
        local block = removed[i]
        local command = "setblock " .. block.pos.x .. " " .. block.pos.y .. " " .. block.pos.z .. " " .. block.block
        if #command > 255 then
            log("Command too long, could not restore")
        else
            host:sendChatCommand(command)
        end
        if i < 5 then
            sounds["entity.ender_eye.death"]:pos(block.pos):subtitle("Skull undeleted"):pitch(1.5):volume(1/i):attenuation(2):play()
        end
        for _ = 1, 20 do
            particles["end_rod"]:pos(block.pos + vec(0.5,0,0.5) + rng.vec3() * 0.2):velocity(rng.vec3() * 0.1):color(vectors.hsvToRGB(rng.float(0,1),0.4,1)):lifetime(rng.float(10,20)):scale(0.3):spawn()
        end
    end
    removed = {}
end)

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
    main_page:newAction():title("§7Mode: §a" .. name):item(item):onLeftClick(function ()
        host:setSlot(player:getNbt().SelectedItemSlot, item)
        sounds["entity.item.pickup"]:pos(player:getPos()):play()
    end)
end

for _, file in next, listFiles("days") do
    giveHead(file:gsub("days[%.%/]",""))
end

while #main_page:getActions() % 8 ~= 0 do
    main_page:newAction():hoverColor(0,0,0)
end
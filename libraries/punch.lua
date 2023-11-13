function events.TICK()
    for _, player_entity in next, world.getPlayers() do
        if player_entity:getSwingTime() == 1 then
            local block = player_entity:getTargetedBlock()
            if block.id:find("head") then
                event:emit("skull_punched", block:getPos(), player_entity)
            end
        end
    end
end
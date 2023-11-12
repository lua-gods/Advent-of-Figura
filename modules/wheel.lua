if not IS_HOST then return end

local main_page = action_wheel:newPage()
action_wheel:setPage(main_page)

local head = "player_head{SkullOwner:" .. avatar:getEntityName() .. "}"
main_page:newAction():title("Head"):item(head):onLeftClick(function ()
    host:setSlot(player:getNbt().SelectedItemSlot, head)
    sounds["entity.item.pickup"]:pos(player:getPos()):play()
end)

local function dayItem(count)
    return world.newItem(count == -1 and "barrier" or "clock", math.abs(count), 5)
end
main_page:newAction():title("Override day (scroll)"):item(dayItem(-1)):onScroll(function (dir, self)
    if not self:isToggled() then return end
    DATE = (DATE or 1) + dir
    self:setItem(dayItem(DATE))
end):onToggle(function (state, self)
    if state then
        DATE = 1
        self:setItem(dayItem(DATE))
    else
        DATE = nil
        self:setItem(dayItem(-1))
    end
end)


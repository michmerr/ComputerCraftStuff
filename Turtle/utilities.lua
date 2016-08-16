--region *.lua
--Date

require("os")
if not utilities then
    utilities = { }
end

function table.contains(list, listItem, caseInsensitive)
    if not list or type(list) ~= "table" then
        return false
    end

    caseInsensitive = caseInsensitive and type(listItem) == "string"
    for i = 0, #list do
        if caseInsensitive and type(list[i]) == "string" then
            if string.lower(list[i]) == string.lower(listItem) then
                return true
            end
        else if list[i] == listItem then
            return true
        end
    end
    return false
end

-- copy of os.sleep, but with check for the event we're expecting
-- returns success, eventParam1, eventParamN, ...
function utilities.waitForEvent(filter, timeout)
    local timer, event, param, notification
    if (timeout and timeout > 0) then
        timer = os.startTimer( timeout )
    end

    repeat
        notification = { os.pullEvent() }
        event, param = table.unpack(notification)
    until param == timer or event == filter or not filter

    if (param ~= timer) then
        return table.unpack(notification)
    end

    return false
end

--endregion

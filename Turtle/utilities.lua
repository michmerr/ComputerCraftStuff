--region *.lua
--Date

if not os then
    require("os")
end
if not utilities then
    utilities = { }
end

function utilites.require(modname)
    if _G[modname] then
        return
    end
    if require then
        require(modname)
    else
        os.loadAPI(modname)
    end
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
        elseif list[i] == listItem then
            return true
        end
    end
    return false
end

local function matchFilter(event, params, filter, filterParams)

    if event ~= filter  then
       return false
    end

    if not filterParams or #filterParams == 0 then
        return true
    end

    for i = 1, #filterParams do
        local fp = filterParams[i]
        if fp ~= nil then
            if type(fp) == "function" then
                if not fp(params[i]) then
                    return false
                end
            elseif fp ~= params[i] then
                return false
            end
        end
    end

    return true
end

-- copy of os.sleep, but with check for the event we're expecting
-- returns success, eventParam1, eventParamN, ...
function utilities.waitForEvent(filter, timeout, ...)
    local timer, event, notification
    local filterParams = { ... }
    local params = { }
    if (timeout and timeout > 0) then
        timer = os.startTimer( timeout )
    end

    repeat
        notification = { os.pullEvent() }
        event, params[1], params[2], params[3], params[4], params[5] = table.unpack(notification)
        --print(string.format("event: %s  p: %s  p: %s  p: %s", tostring(event), tostring(params[1]), tostring(params[2]), tostring(params[3])))
    until (event == "timer" and params[1] == timer) or matchFilter(event, params, filter, filterParams)

    if not (event == "timer" and params[1] == timer) then
        return table.unpack(notification) or true
    end

    return false
end

function string.split(s, separator)
    local result = { }
    local sepWidth = string.len(separator)
    local index = ( sepWidth * -1) + 1
    local toIndex
    while index do
        toIndex = string.find(s, separator, index + sepWidth) + 1
        if toIndex then
            table.insert(result, string.sub(index, toIndex))
        else
            table.insert(result, string.sub(index))
        end
        index = toIndex
    end

    return result
end
--endregion

--region *.lua
--Date

if not os then
    require("os")
end
if not utilities then
    utilities = { }
end

function utilities.require(modname)
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

local function matchFilter(event, params, filters)

    if not filters or #filters == 0 then
        return false
    end

    for f = 1, #filters do
        if event ~= filters[f][1] then
            return false
        end

        if #filters[f] < 2 then
            return true
        end

        for i = 2, #filters[f] do
            local fp = filters[f][i]
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
    end
    return true
end

-- copy of os.sleep, but with check for the event we're expecting
-- returns success, eventParam1, eventParamN, ...
function utilities.waitForEvent(timeout, ...)
    local timer, event, notification
    local filters = { ... }
    local params = { }
    if (timeout and timeout > 0) then
        timer = os.startTimer( timeout )
    end

    repeat
        notification = { os.pullEvent() }
        event, params[1], params[2], params[3], params[4], params[5] = table.unpack(notification)
        --print(string.format("event: %s  p: %s  p: %s  p: %s", tostring(event), tostring(params[1]), tostring(params[2]), tostring(params[3])))
    until (event == "timer" and params[1] == timer) or matchFilter(event, params, filters)

    if not (event == "timer" and params[1] == timer) then
        return notification or true
    end

    return false
end

function string.split(s, separator, removeEmpty)
    local result = { }
    local sepWidth = string.len(separator)
    local index = ( sepWidth * -1) + 1
    local toIndex
    while index do
        toIndex = string.find(s, separator, index + sepWidth)
        if toIndex then
            table.insert(result, string.sub(s, index, toIndex - 1))
            toIndex = toIndex + 1
        else
            table.insert(result, string.sub(s, index))
        end
        index = toIndex
    end

    return result
end

local keyPattern = "['%s']"
local indexPattern = "[%d]"

function utilities.serialize(value, indent)
    local result, pattern
    if not indent then
        indent = 0
    end
    -- string.format isn't honoring leading spaces in the CC version
    local margin = string.rep("  ", indent)




    if type(value) == "string" then
        result = string.format("%q", value)
    elseif type(value) == "number" then
        result = string.format("%d", value)
    elseif type(value) == "boolean" then
        result = tostring(value)
    elseif type(value) == "table" then
        result = "{\n"
        for k,v in pairs(value) do
            local serializedValue
            if type(k) == "string" then
                pattern = "%s"..keyPattern.." = %s;\n"
            else
                pattern = "%s"..keyPattern.." = %s;\n"
            end
            serializedValue = v and v.serialize(indent + 1) or utilities.serialize(v, indent + 1)
            result = result..string.format(pattern, margin, k, serializedValue)
        end
        result = result..margin.."}"
    end

    return result
end
--endregion

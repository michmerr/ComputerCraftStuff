--region *.lua
--Date

if not utilities then
    if require then
        require("utilities")
    else
        os.loadAPI("utilities")
    end
end
if require then require("fs") end

local itemTypeBase = { }
local mt = { __index = itemTypeBase }

function fromItemDetail(metadata)
    local self = { }

    self.fullname = metadata.name
    self.namespace, self.name = table.unpack(string.split(metadata.name, ":"))
    self.damage = metadata.damage
    return setmetatable(self, mt)
end

function fromString(itemString)
    local self = { }
    self.namespace, self.name, self.damage = string.split(itemString, ":")
    self.fullname = self.namespace..":"..self.name
    return setmetatable(self, mt)
end

function deserialize(itemString)
    return loadstring(itemString)
end

local stringPattern = "%s  %s = %q;\n"
local numberPattern = "%s  %s = %d;\n"
local boolPattern = "%s  %s = %s;\n"

function itemTypeBase:serialize()
    local result = "{\n"

    if self.friendlyName then
        result = string.format(stringPattern, result, "friendlyName", friendlyName)
    end
    for k, v in pairs(self) do
        if k ~= "friendlyName" then
            local pattern
            if type(v) == "string" then
                pattern = stringPattern
            elseif type(v) == "number" then
                pattern = numberPattern
            elseif type(v) == "boolean" then
                pattern = boolPattern
            end
            if pattern then
                result = string.format(pattern, result, k, v)
            end
        end
    end

    result = result + "}"
    return result
end

function itemTypeBase:equals(m)
    if not m then
        return false
    end

    if type(m) == "string" then
        return m == self.tostring()
    end

    if type(m) ~= "table" then
        return false
    end

    return self.damage == m.damage and self.name == m.name and self.namespace == m.namespace
end

function itemTypeBase:tostring()
    return string.format("%s:%d", self.fullname, self.damage)
end

mt.__eq = itemTypeBase.equals
mt.__tostring = itemTypeBase.tostring

--endregion
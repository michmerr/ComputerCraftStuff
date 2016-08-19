--region *.lua
--Date

if not utilities then
    if require then
        require("utilities")
    else
        dofile("utilities")
    end
end
if require then require("fs") end

itemType = { }
local mt = { __index = itemType }

function itemType.fromItemDetail(metadata)
    local self = { }

    self.fullname = metadata.name
    self.namespace, self.name = table.unpack(string.split(metadata.name, ":"))
    self.damage = metadata.damage
    return setmetatable(self, mt)
end

function itemType.fromString(itemString)
    local self = { }
    self.namespace, self.name, self.damage = string.split(itemString, ":")
    self.fullname = self.namespace..":"..self.name
    return setmetatable(self, mt)
end

function itemType:equals(m)
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

function itemType:tostring()
    return string.format("%s:%d", self.fullname, self.damage)
end

mt.__eq = itemType.equals
mt.__tostring = itemType.tostring

itemTypeCollection = { }
local mtc = { __index = itemTypeCollection }

local function tryLoad(filename)
    local file = assert(io.open(filename, "r"), "File note found: "..filename)
    local list = file:read("*all")
    return itemTypeCollection.new(string.split(list, "\n"))
end

function itemTypeCollection.new(list)
    local self = { }
    local hash = { }

    if list then
        if type(list) == "string" then
            return tryLoad(list)
        elseif type(list) == "table" then
            if #list > 0 then
                local ctor, item
                if type(list[1]) == "table" then
                    ctor = list[1].namespace and itemType.fromItemType or itemType.fromItemDetail
                elseif type(list[1]) == "string" then
                    ctor = itemType.fromString
                end
                for i = 1, #list do
                    item = ctor(list[i])
                    hash[item.tostring()] = item
                end
            end
        else
            error(string.format("Not sure what to do with argument of type %s. Try a filename or list of itemTypes instead.", type(list)))
        end
    end

    function self.count()
        return #hash
    end

    function self.add(item)
        hash[item.tostring()] = item
    end

    function self.get(item)
        if type(item) == "table" then
            if item.namespace then
                return hash[item.tostring()]
            elseif item.nam and item.damage then
                return hash[item.name..":"..item.damage]
            else
                return nil
            end
        elseif type(item) == "string" then
            return hash[item]
        elseif type(item) == "number" then
            return hash[item]
        else
            return nil
        end
    end

    function self.remove(item)
        if type(item) == "table" then
            if item.namespace then
                hash[item.tostring()] = nil
            elseif item.nam and item.damage then
                hash[item.name..":"..item.damage] = nil
            end
        elseif type(item) == "string" then
            hash[item] = nil
        elseif type(item) == "number" then
            hash[item] = nil
        end
    end

    function self.pairs()
        return pairs(hash)
    end

    return setmetatable(self, mtc)

end

function itemTypeCollection:contains(item)
    return self.get(item) and true
end
--endregion

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

local itemTypeBase = { }
local mt = { __index = itemTypeBase }

function new(o)
    local self = o or {
        namespace = "";
        name = "";
        friendlyName = "";
        fullname = "";
        damage = "";
        compactRecipe = 511;   --- simple pattern of what arrangement of this item (and only this item) results in a "compacted" output
    }
    return setmetatable(self, mt)
end

function deserialize(itemString)
    return setmetatable(loadstring(itemString)(), mt)
end

function itemTypeBase:isSlotFilledForCompact(slotNumber)
    if slotNumber < 1 or slotNumber > 9 or not self.compactRecipe or self.compactRecipe == 0 then
        return false
    end

    if self.compactRecipe == 511 then
        return true
    end

    local mask = bit.blshift(1, slotNumber - 1)
    return bit.band(mask, compactRecipe) == slotNumber
end

function itemTypeBase:setCompactRecipe(slotsFilled)
    if not slotsFilled then
        self.compactRecipe = 0
    end

    if type(slotsFilled) == "number" then
        self.compactRecipe = slotsFilled
    elseif type(slotsFilled) == "string" then
        local recipe = 0
        for i = 1, string.len(slotsFilled) do
            if slotsFilled[i] ~= " " then
                recipe = bit.band(recipe, bit.blshift(1, i - 1))
            end
        end
        self.compactRecipe = recipe
    elseif type(slotsFilled) == "boolean" then
        self.compactRecipe = slotsFilled and 511 or 0
    end
end

function itemTypeBase:serialize(indent)
    return utilities.serialize(indent)
end

function itemTypeBase:equals(m)
    if not m then
        return false
    end

    if type(m) == "string" then
        return m == self.getId()
    end

    if type(m) ~= "table" then
        return false
    end

    return (m.getId and m.getId() == self.getId()) or (self.damage == m.damage and self.fullname == m.name)
end

function itemTypeBase:getId()
    return string.format("%s:%s", self.fullname, self.damage)
end

mt.__eq = itemTypeBase.equals
mt.__tostring = itemTypeBase.getId

--endregion
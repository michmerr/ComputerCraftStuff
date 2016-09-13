-- region *.lua
-- Date

if not utilities then
  dofile("/terp/utilities")
end

local itemTypeBase = { }
local mt = { __index = itemTypeBase }

COMPACT_9_X_9 = 0x1ff
COMPACT_4_X_4 = 0x1b
COMPACT_NONE = 0x0

function new(o)
  local self = o or {
    namespace = "";
    name = "";
    friendlyName = "";
    fullname = "";
    damage = "";
    compactRecipe = COMPACT_NONE;--- bit pattern of what arrangement of this item type results in a "compacted" output
  }
  if o and not o.fullname then
    self.fullname = string.format("%s:%s", self.namespace, self.name)
  end

  return setmetatable(self, mt)
end

function isa(o)
  return getmetatable(o) == mt
end

function deserialize(itemString)
  return setmetatable(loadstring(itemString)(), mt)
end

function itemTypeBase:isSlotFilledForCompact(slotNumber)
  if slotNumber < 1 or slotNumber > 9 or not self.compactRecipe or self.compactRecipe == 0 then
    return false
  end

  if self.compactRecipe == COMPACT_9_X_9 then
    return true
  end

  local mask = bit.blshift(1, slotNumber - 1)
  return bit.band(mask, compactRecipe) == slotNumber
end

function itemTypeBase:setCompactRecipe(slotsFilled)
  if not slotsFilled then
    self.compactRecipe = COMPACT_NONE
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
    self.compactRecipe = slotsFilled and COMPACT_9_X_9 or COMPACT_NONE
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

  return(m.getId and m.getId() == self.getId()) or(self.damage == m.damage and self.fullname == m.name)
end

function itemTypeBase:getId()
  return string.format("%s:%s", self.fullname, self.damage)
end

mt.__eq = itemTypeBase.equals
mt.__tostring = itemTypeBase.getId

-- endregion
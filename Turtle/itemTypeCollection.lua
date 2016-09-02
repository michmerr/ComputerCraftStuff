-- region *.lua
-- Date
local itemTypeCollectionBase = { }
local mt = { __index = itemTypeCollectionBase }

function new(list)
  local self = list or { }
  return setmetatable(self, mt)
end

function load(filename)
  local file = assert(io.open(filename, "r"), "File not found: " .. filename)
  local raw = file:read("*a")
  local list = loadstring("return " .. raw)()
  return new(list)
end

function itemTypeCollectionBase:get(item)
  if type(item) == "table" then
    for i = 1, #self do
      if self[i].equals(item) then
        return self[i]
      end
    end
  elseif type(item) == "string" then
    for i = 1, #self do
      if self[i].getId() == item then
        return self[i]
      end
    end
  elseif type(item) == "number" then
    return self[item]
  end
  return nil
end

function itemTypeCollectionBase:remove(item)
  if type(item) == "number" then
    return table.remove(self, item)
  end

  local id
  if type(item) == "table" then
    if item.getId then
      id = item.getId()
    elseif item.name and item.damage then
      id = item.name .. ":" .. item.damage
    end
  elseif type(item) == "string" then
    id = item
  end

  if id then
    local index = -1
    for i = 1, #self do
      if self[i].getId() == id then
        index = i
        break
      end
    end
    if index > 0 then
      return table.remove(self, index)
    end
  end

  return false
end

function itemTypeCollectionBase:contains(item)
  return self.get(item) and true
end

function itemTypeCollectionBase:serialize()
  local result = "{\n"
  for i = 1, self.count() do
    result = result .. self.get(i).serialize() .. ";\n"
  end
  result = result .. "}"
  return result;
end

-- endregion

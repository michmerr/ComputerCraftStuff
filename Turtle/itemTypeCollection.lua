-- region *.lua
-- Date
if not itemType then
  os.loadAPI("terp/itemType")
end

local itemTypeCollectionBase = { }
local mt = { __index = itemTypeCollectionBase }

function new(list)
  local self = { }
  if list then
    for i = 1, #list do
      table.insert(self, itemType.new(list[i]))
    end
  end
  return setmetatable(self, mt)
end

function load(filename)
  local file = assert(io.open(filename, "r"), "File not found: " .. filename)
  local raw = file:read("*a")
  local list = loadstring("return " .. raw)()
  return new(list)
end

function itemTypeCollectionBase:where(test)
  assert(test, "Expected a function taking an itemType as an argument")
  local result = { }
  for i = 1, #self do
    if test(self[i]) then
      table.insert(result, self[i])
    end
  end
  return new(result)
end

function itemTypeCollectionBase:get(item)
  if type(item) == "table" then
    for i = 1, #self do
      if self[i]:equals(item) then
        return self[i]
      end
    end
  elseif type(item) == "string" then
    for i = 1, #self do
      if self[i]:getId() == item then
        return self[i]
      end
    end
  elseif type(item) == "number" then
    return self[item]
  end
  return nil
end

function itemTypeCollectionBase:add(item)
  if type(item) == "table" then
    if item.getId then
      table.insert(self, item)
    else
      table.insert(self, itemType.new(item))
    end
  elseif type(item) == "string" then
    table.insert(self, itemType.deserialize(item))
  else
    return false
  end
  return true
end

function itemTypeCollectionBase:remove(item)
  if type(item) == "number" then
    return table.remove(self, item)
  end

  local id
  if type(item) == "table" then
    if item.getId then
      id = item:getId()
    elseif item.name and item.damage then
      id = item.name .. ":" .. item.damage
    end
  elseif type(item) == "string" then
    id = item
  end

  if id then
    local index = -1
    for i = 1, #self do
      if self[i]:getId() == id then
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
  return self:get(item) and true
end

function itemTypeCollectionBase:serialize()
  local result = "{\n"
  for i = 1, self:count() do
    result = result .. self:get(i):serialize() .. ";\n"
  end
  result = result .. "}"
  return result;
end

-- endregion

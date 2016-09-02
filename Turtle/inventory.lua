-- region *.lua

if not utilities then
  dofile("utilities")
end
if not terp then
  os.loadAPI("terp")
end
if not itemTypeCollection then
  os.loadAPI("itemTypeCollection")
end
if not waypointCollection then
  os.loadAPI("waypointCollection")
end

local base = { }
for k, v in pairs(turtle) do
  base[k] = v
end

local function selectMatching(func, low, high)
  low = low or 1
  high = high or 16
  for i = low, high do
    if func(i) then
      base.select(i)
      return true
    end
  end
  return false
end

function turtle.selectEmpty(low, high)
  return selectMatching(
    function(slot)
      return turtle.getItemCount(slot) == 0
    end,
    low, high)
end

function turtle.selectItemType(itemType, low, high)
  return selectMatching(
    function(slot)
      local slotItem = turtle.getItemDetail(slot)
      if not slotItem or slotItem.count == 0 then
        return not itemType
      end
      if not itemType then
        return false
      end
      if type(itemType) == "table" and #itemType > 0 then
        for i = 1, #itemType do
          if itemType[i].equals(slotItem) then
            return true
          end
        end
        return false
      end
      return itemType.equals(slotItem)
    end,
    low, high)
end

function turtle.select(...)
  local args = { ... }
  assert(#args < 4, "Expecting fewer than four arguments")

  if #args == 0 then
    return turtle.selectEmpty()
  end

  if #args == 1 then
    if type(args[1]) == number then
      return base.select(args[1])
    end

    return selectMatching(args[1])
  end

  if #args == 2 then
    return turtle.selectEmpty(args[1], args[2])
  end

  return turtle.selectMatching(args[1], args[2], args[3])

end

-- Might want to separate out the return for unloading into a derived
-- location-aware inventory class/API/whatever to reduce the number of dependencies
-- for core inventory stuff.

function turtle.getRequiredUnloadContainer()
  --TODO
end

function turtle.setRequiredUnloadContainer(container)
  --TODO
end

function turtle.getUnloadPoint()
  --TODO
end

function turtle.setUnloadPoint(waypoint)
  --TODO
end

function turtle.checkFull()
  -- TODO
end

function extension.waitForOffload(returnToWaypoint)
  -- TODO
end



-- endregion

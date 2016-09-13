-- region *.lua

if not utilities then
  dofile("/terp/utilities")
end
if not terp then
  os.loadAPI("/terp/terp")
end
if not itemTypeCollection then
  os.loadAPI("/terp/itemTypeCollection")
end
if not waypointCollection then
  os.loadAPI("/terp/waypointCollection")
end

allItems = itemTypeCollection.load("/terp/itemTypeData")

local function defaultLowHigh(low, high)
  low = low or 1
  high = high or 16
  return low, high
end

function selectMatching(func, low, high)
  Logger.log(Logger.levels.DEBUG, "selectMatching %s, %s, %s", tostring(func), tostring(low), tostring(high))
  low, high = defaultLowHigh(low, high)
  Logger.log(Logger.levels.DEBUG, "selectMatching between %d and %d", low, high)
  if func(terp.getItemDetail()) then
    return true
  end

  for i = low, high do
    if func(terp.getItemDetail(i)) then
      --print("found and %s is %s", tostring(i), type(i))
      terp.select(i)
      return true
    end
  end
  return false
end

function terp.selectEmpty(low, high)
  low, high = defaultLowHigh(low, high)
  if terp.getItemCount() == 0 then
    return true
  end

  for i = low, high do
    if terp.getItemCount(i) == 0 then
      terp.select(i)
      return true
    end
  end
  return false
end

function terp.selectItemType(itemType, low, high)
  --print(string.format("selectItemType %s, %s, %s", tostring(itemType), tostring(low), tostring(high)))
  low, high = defaultLowHigh(low, high)
  --print(string.format(" selectItemType %s, %s, %s", tostring(itemType), tostring(low), tostring(high)))
  if type(itemType) == "function" then
    return selectMatching(itemType, low, high)
  end

  return selectMatching(
    function(slotItem)
      if not slotItem or slotItem.count == 0 then
        return not itemType
      end
      if not itemType then
        return false
      end
      if type(itemType) == "table"  then
        if itemType.contains then
          --print("Checking to see if itemTypeCollection contains slotItem")
          return itemType:contains(slotItem)
        elseif #itemType > 0 then
          --print("Checking to see if list contains slotItem")
          for i = 1, #itemType do
            --print("Comparing itemType to slotItem")
            if itemType[i]:equals(slotItem) then
              return true
            end
          end
        end
        return false
      end
      return itemType.equals(slotItem)
    end,
    low, high)
end

function terp.select(...)
  local args = { ... }
  assert(#args < 4, "Expecting fewer than four arguments")

  if #args == 0 then
    return terp.selectEmpty()
  end

  if #args == 1 then
    if type(args[1]) == "number" then
      return turtle.select(args[1])
    end

    return selectMatching(args[1])
  end

  if #args == 2 then
    return terp.selectEmpty(args[1], args[2])
  end

  return terp.selectMatching(args[1], args[2], args[3])

end

function terp.resupply(slotLow, slotHigh, itemType)
  -- this could get tricky, since we can't count on there being any sort of
  -- clear vertical return route as there is in an excavation. This problem means
  -- code to walk up and down the stairs as part of the navigation.

  -- or just hang out until a human comes to do the resupply

  slotLow, slotHigh = defaultLowHigh(slotLow, slotHigh)
  print(string.format("I'm out of required stuff. Put it in slots %d-%d!", slotLow, slotHigh))
  repeat
    notification = { os.pullEvent() }
    event, p1 = table.unpack(notification)
    if event == "key" and p1 == 57 then
      exit()
    end
  until event == "turtle_inventory" and terp.selectItemType(itemType, slowLow, slotHigh)
  print("Waiting 10 seconds for additional stuff...")
  os.sleep(10)
  print("Go time!")
end

-- TODO: migrate this to inventory
local function place(placeFunc, slotLow, slotHigh, itemType)
  --print(string.format("place %s, %s, %s, %s", tostring(placeFunc), tostring(slotLow), tostring(slotHigh), tostring(itemType)))
  if not terp.selectItemType(itemType, slotLow, slotHigh) then
    terp.resupply(slotLow, slotHigh)
  end

  return placeFunc()
end

function terp.placeItem(itemType, slotLow, slotHigh)
  return place(terp.place, slotLow, slotHigh, itemType)
end

function terp.placeItemUp(itemType, slotLow, slotHigh)
  return place(terp.placeUp, slotLow, slotHigh, itemType)
end

function terp.placeItemDown(itemType, slotLow, slotHigh)
  return place(terp.placeDown, slotLow, slotHigh, itemType)
end

-- Might want to separate out the return for unloading into a derived
-- location-aware inventory class/API/whatever to reduce the number of dependencies
-- for core inventory stuff.

function terp.getRequiredUnloadContainer()
  --TODO
end

function terp.setRequiredUnloadContainer(container)
  --TODO
end

function terp.getUnloadPoint()
  --TODO
end

function terp.setUnloadPoint(waypoint)
  --TODO
end

function terp.checkFull()
  -- TODO
end

function terp.waitForOffload(returnToWaypoint)
  -- TODO
end



-- endregion

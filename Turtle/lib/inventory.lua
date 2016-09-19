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

allItems = itemTypeCollection.load("/terp/lib/itemTypeData")
local settings = { }

local function defaultLowHigh(low, high)
  low = low or 1
  high = high or 16
  return low, high
end

function selectMatching(func, low, high)
  Logger.log(Logger.levels.DEBUG, "selectMatching %s, %s, %s", tostring(func), tostring(low), tostring(high))
  low, high = defaultLowHigh(low, high)
  Logger.log(Logger.levels.DEBUG, "selectMatching between %d and %d", low, high)

  local currentSlot = terp.getSelectedSlot()
  -- check the currently selected slot first
  Logger.log(Logger.levels.DEBUG, "checking current slot (%d)", currentSlot)
  if currentSlot >= low and currentSlot <= high and func(terp.getItemDetail()) then
    Logger.log(Logger.levels.DEBUG, "using current slot")
    return true
  end

  for i = low, high do
    if i ~= currentSlot then
      Logger.log(Logger.levels.DEBUG, "checking slot (%d)", i)
      if func(terp.getItemDetail(i)) then
        --print("found and %s is %s", tostring(i), type(i))
        terp.select(i)
        return true
      end
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
      Logger.log(Logger.levels.DEBUG, " Seeking ItemType: %s", itemType and tostring(itemType) or "Any")
      Logger.log(Logger.levels.DEBUG, " Current slot item:")
      if not slotItem then
        Logger.log(Logger.levels.DEBUG, "  NONE")
        return false
      else
        for k,v in pairs(slotItem) do
          Logger.log(Logger.levels.DEBUG, "    %s = %s", k, tostring(v))
        end
      end
      if slotItem.count == 0 then
        Logger.log(Logger.levels.DEBUG, " NONE")
        return false
      end
      if not itemType then
        Logger.log(Logger.levels.DEBUG, " Matched ANY item")
        return true
      end
      if type(itemType) == "table"  then
        if itemType.contains then
          Logger.log(Logger.levels.DEBUG, "Checking to see if itemTypeCollection contains slotItem")
          return itemType:contains(slotItem)
        elseif #itemType > 0 then
          Logger.log(Logger.levels.DEBUG, "Checking to see if list contains slotItem")
          for i = 1, #itemType do
            Logger.log(Logger.levels.DEBUG, "Comparing itemType to slotItem")
            if itemType[i]:equals(slotItem) then
              return true
            end
          end
        end
        return true
      end
      Logger.log(Logger.levels.DEBUG, " Matched ANY item")
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
  return settings.unloadContainerType
end

function terp.setRequiredUnloadContainer(container)
  -- TODO add checking for supported formats (string description, itemType, function, etc.)
  settings.unloadContainerType = container
end


-- TODO address the fact that the consolidation loop could move items from slot ranges defined for job materials
-- into lower numbered slots if the same material is picked up or placed in a lower slot...
function terp.consolidateItems()
  local selected = turtle.getSelectedSlot()
  for i = 1, 16 do
    if turtle.getItemCount(i) > 0 then
      local free = turtle.getItemSpace(i)
      if i > 0 then
        local detail = turtle.getItemDetail(i)
        for j = i + 1, 16 do
          local checkDetail = turtle.getItemDetail(j)
          if detail.name == checkDetail.name and detail.damage == checkDetail.damage then
            turtle.select(j)
            turtle.transferTo(i, free)
            free = turtle.getItemSpace(i)
            if free == 0 then
              break
            end
          end
        end
      end
    end
  end
  
  if selected ~= turtle.getSelectedSlot() then
    turtle.select(selected)
  end
end

function terp.checkFull()
  local full = true
  for i = 1, 16 do
    if turtle.getItemCount(i) == 0 then
      full = false
      break
    end
  end

  -- see if consolidating frees up any slots
  if full then
    terp.consolidateItems()
    full = true
    for i = 1, 16 do
      if turtle.getItemCount(i) == 0 then
        full = false
        break
      end
    end  
  end

  return full
end

function terp.waitForOffload(returnToWaypoint)
  -- TODO
end



-- endregion

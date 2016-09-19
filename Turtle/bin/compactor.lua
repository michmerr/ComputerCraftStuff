-- region *.lua
-- Date

if not utilities then
  dofile("utilities")
end

if not itemTypeCollection then
  os.loadAPI("itemTypeCollection")
end

local configFile
local args = { ...}

if #args > 0 then
  configFile = args[1]
end



local config = {
  ["craftingSlots"] = { 1; 2; 3; 5; 6; 7; 9; 10; 11 };
  ["outputSlot"] = 16;
  -- Filters to send items down/left/right.
  -- These can be any table with a "contains" function to match metadata from turtle.getItemDetail()
  ["downNames"] = nil;
  ["leftNames"] = nil;
  ["rightNames"] = { contains = function(item) return true end };
  -- instance of itemTypeCollection listing the types that can be compacted, and how.
  ["compact"] = itemTypeCollection.load("itemTypeData");
  ["interval"] = 30;
}

local slotCache = { }

local sideTurn = turtle.turnLeft
local defaultTurn = turtle.turnRight
local pushTo = turtle.drop
local pullFrom = turtle.suckUp
local pushBack = turtle.dropUp

local done = false
local current, detail, count, split
local max = 64 * 9

function toggleInputOutputBins()
  if pushTo == turtle.drop then
    pushTo = turtle.dropUp
    pullFrom = turtle.suck
    pushBack = turtle.drop
  else
    pushTo = turtle.drop
    pullFrom = turtle.suckUp
    pushBack = turtle.dropUp
  end
end

function loadConfig()
  if not configFile then
    return
  end
end

function init()
  flush()

  if configFile then
    loadConfig()
  end

  if config.outDirection == "left" then
    sideTurn = turtle.turnRight
    defaultTurn = turtle.turnLeft
  end
end

function okToPush(inspectFunc)
  local success, data = inspectFunc()
  return success and data.name == "minecraft:chest"
end

function push(turn, turnBack, indices)
  if not indices or type(indices) ~= "table" then
    return false
  end

  turn()
  local result = false
  if okToPush(turtle.inspect) then
    for i = 1, #indices do
      turtle.select(indices[i])
      result = pushTo()
      if not result then
        break
      end
    end
  end
  turnBack()
  return result
end

function flush()
  for i = 1, 16 do
    turtle.select(i)
    pushTo()
  end
  slotCache = { }
end

function printMetadata(metadata)
  print(string.format("%s:%s (%s/%s) [%s]", metadata.name, tostring(metadata.damage), tostring(metadata.count), tostring(metadata.space), tostring(metadata.indexFound)))
end

function transfer(toSlot, from, to, amount, leave)

  if not leave then
    leave = 0
  end

  local have = from.count - leave

  if have <= 0 then
    return false
  end

  transferAmount = math.min(amount, have)

  turtle.transferTo(toSlot, transferAmount)

  from.count = from.count - transferAmount
  to.count = to.count + transferAmount

end

function filter()
  local keep, itemData, noneLeft

  print "Filtering out items that will not be kept and compacted."

  repeat
    pushSide = { }
    pushDefault = { }

    turtle.select(1)
    repeat until not pullFrom()

    for i = 1, 16 do
      turtle.select(i)
      itemData = turtle.getItemDetail()
      if not itemData then
        if i < 16 then
          noneLeft = true
        end
      elseif config.compact.get(itemData) then
        pushTo()
      elseif config.dropNames and config.dropNames.get(itemData) then
        turtle.dropDown()
      else
        if config.sideNames and config.sideNames.get(itemData) then
          table.insert(pushSide, i)
        else
          table.insert(pushDefault, i)
        end
      end
    end

    if #pushSide > 0 then
      push(sideTurn, defaultTurn, pushSide)
    end

    if #pushDefault > 0 then
      push(defaultTurn, sideTurn, pushDefault)
    end

  until noneLeft
end

function getSameItem(pullFunc, pushFunc, item)
  local result, err
  while pullFunc() do
    result = turtle.getItemDetail()
    if item.equals(result) then
      break
    end
    if not pushFunc() then
      err = "Push failed"
      break
    end
  end
  return err, result
end

function pushFilteredItem(pushFunc, fallbackPushFuncs, turnFunc)

  local err

  if turnFunc then
    turnFunc()
  end

  if okToPush(turtle.inspect) and not pushFunc() then
    err = "Push failed"
  end

  if turnFunc then
    if turnFunc == turtle.turnRight then
      turtle.turnLeft()
    else
      turtle.turnRight()
    end
  end

  if not err then
    return nil, true
  end

  if fallbackPushFuncs then
    if type(fallbackPushFuncs) == "function" then
      if fallbackPushFuncs() then
        return err, true
      end
      err = err .. "...could not push to alternate location."
    else
      for i = 1, #fallbackPushFuncs do
        if fallbackPushFuncs[i]() then
          return err, true
        end
        err = err .. "...could not push to alternate location #" .. tostring(i)
      end
    end
  end
  return err, false
end

function functionApplyFilter(item, filter, pushFunc, fallbackPushFuncs, turnFunc)
  local err, result

  if filter and filter.contains(item) then
    err, result = pushFilteredItem(pushFunc, fallbackPushFuncs, turnFunc)
    if err then
      print(err)
      if result then
        err = nil
      end
    end
  end

  return err, result
end


function filterSelectedItem(metadata)
  if not metadata then
    return nil
  end

  local item = itemType.fromItemDetail(metadata)
  if config.compact.contains(item) then
    return nil, item
  end

  local err, result = functionApplyFilter(item, config.dropNames, turtle.dropDown, { pushTo, pushBack })
  if err then
    return err
  end
  if result then
    return nil
  end

  err, result = functionApplyFilter(item, config.rightNames, turtle.drop, { pushTo, pushBack }, turtle.turnRight)
  if err then
    return err
  end
  if result then
    return nil
  end

  err, result = functionApplyFilter(item, config.leftNames, turtle.drop, { pushTo, pushBack }, turtle.turnLeft)
  if err then
    return err
  end
  return nil
end

function findCompactableStack(minimum)
  local err, matchingType
  local metadata

  repeat
    if not pullFrom() then
      sleep(1)
      -- allow for possible race condition
      if not pullFrom() then
        break
      end
    end
    metadata = turtle.getItemDetail()
    err, matchingType = filterSelectedItem(metadata)
    if err then
      return err
    end
    if matchingType and minimum and metadata.count < minimum then
      if not pushTo() then
        return "output full"
      end
      matchingType = nil
    end
  until matchingType

  return err, metadata, matchingType
end

function fillCraftingTable()

  print("Filling the crafting table")

  local result = { }
  local foundType
  turtle.select(config.craftingSlots[1])

  local err, metadata, matchingType = findCompactableStack(9)
  if err then
    return err
  end
  if not matchingType then
    return nil
  end

  metadata.space = turtle.getItemSpace()
  table.insert(result, metadata)

  for i = 2, #config.craftingSlots do
    turtle.select(config.craftingSlots[i])
    err, metadata, foundType = findCompactableStack()
    if err then
      return err
    end
    if not foundType then
      return nil, result
    end
    if foundType ~= matchingType then
      if not pushBack() then
        if not pushTo() then
          return "output full"
        end
      end
      return nil, result
    end

    metadata.space = turtle.getItemSpace()
    table.insert(result, metadata)
  end

  return nil, result
end

function totalCount(metadata)
  local result = 0
  --    print("Add totals")
  for i = 1, #metadata do
    --      print(i)
    if metadata[i] then
      --        printMetadata(metadata[i])
      result = result + metadata[i].count
    end
  end
  return result
end

function getSlotCount(metadata, index)
  local slotData = metadata[index]
  return slotData and slotData.count or 0
end

function crossLevel(metadata, indexA, indexB, level)
  local a, b
  for i = 1, #metadata do
    if metadata[i].foundIndex == config.craftingSlots[indexA] then
      a = metadata[i]
    elseif metadata[i].foundIndex == config.craftingSlots[indexB] then
      b = metadata[i]
    end
  end
  local a = metadata[indexA]
  local b = metadata[indexB]
  --   print(string.format("%d %d %d %d : %d %d %d %d", a.count, indexA, a.foundIndex, config.craftingSlots[indexA], b.count, indexB, b.foundIndex, config.craftingSlots[indexB]))
  if (a.count >= level and b.count >= level) or(a.count <= level and b.count <= level) then
    return
  end

  local to, from, need

  if a.count > b.count then
    fromSlot = config.craftingSlots[indexA]
    toSlot = config.craftingSlots[indexB]
    from = a
    to = b
  else
    fromSlot = config.craftingSlots[indexB]
    toSlot = config.craftingSlots[indexA]
    from = b
    to = a
  end

  need = level - to.count

  turtle.select(fromSlot)

  transfer(toSlot, from, to, need, level)
end

-- returns true if there were enough items to spread into an
-- even 3x3 grid. When successful, any missing crafting slot
-- entries are populated.
function levelValues(metadata)
  local total = totalCount(metadata)
  print(string.format("Total = %d", total))
  local extra, slot, checkSlot, need, value

  -- Not enough items to spread into a 3x3 grid
  if total < 9 then
    return false
  end

  local maxStack = metadata[1].space + metadata[1].count
  -- The grid is already full
  if total ==(maxStack * 9) then
    return true
  end

  -- Initialize metadata for empty slots
  for i = #metadata + 1, #config.craftingSlots do
    local blank = { }
    blank.count = 0
    blank.space = maxStack
    table.insert(metadata, blank)
  end

  local split = math.floor(total / 9)
  print(string.format("Average = %d", split))

  for i = 1, #config.craftingSlots - 1 do
    if metadata[i].count ~= split then
      for j = i + 1, #config.craftingSlots do
        crossLevel(metadata, i, j, split)
        if metadata[i].count == split then
          break
        end
      end
    end
  end
  return true
end

-- return true if any stacks were compacted, which also indicates that the set of stacks has changed.
function compact()
  local slotsFilled
  local slotsFilledCount

  local result = false
  repeat
    local err, slotsFilled = fillCraftingTable()
    if err then
      return err
    end
    if slotsFilled and #slotsFilled > 0 then

      if levelValues(slotsFilled) then
        turtle.select(config.outputSlot)
        print("crafting...")
        if turtle.craft() then
          print("success!")
          result = true
          if not pushTo() then
            print("problem pushing output forward, will push back instead")
            if not pushBack() then
              return "bins full"
            end
          end
        end
      end

      for i = 1, #config.craftingSlots do
        if turtle.getItemCount(config.craftingSlots[i]) > 0 then
          turtle.select(config.craftingSlots[i])
          if not pushTo() then
            print("problem pushing remainder forward, will push back instead")
            if not pushBack() then
              return "bins full"
            end
          end
        end
      end
    end
  until not slotsFilled or #slotsFilled == 0
  return nil, result
end

init()
repeat
  -- filter()
  local err, result, waitResult

  -- Run stacks back and forth between the two bins until no compact operations take place.
  repeat
    toggleInputOutputBins()
    err, result = compact()
  until not result

  if err then
    print("ERROR: " .. err)
    break
  end
  print(string.format("Waiting %d seconds before next cycle... ([space] to break)", config.interval))

  waitResult = utilities.waitForEvent(config.interval, { "key" })

until waitResult and waitResult[2] == 57


-- endregion
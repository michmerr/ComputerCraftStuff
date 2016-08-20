--region *.lua
--Date

if not turtle then
    require("turtle")
end
if not os then
    require("os")
end

if not utilities then
    if require then
        require("utilities")
    else
        os.loadAPI("utilities")
    end
end

utiltities.require("itemType")
utiltities.require("itemTypeCollection")

local configFile
local args = { ... }

if #args > 0 then
    configFile = args[1]
end

local itemlist = itemTypeCollection.new( {
    "minecraft:coal:0";
    "minecraft:cobblestone:0";
    "ExtraUtilities:cobblestone_compressed:0";  -- Compressed cobblestone
    "ExtraUtilities:cobblestone_compressed:1";  -- Double cobble
    "ExtraUtilities:cobblestone_compressed:2";  -- Triple cobble
    "ExtraUtilities:cobblestone_compressed:3";  -- Quad cobble
    "minecraft:dirt:0";
    "ExtraUtilities:cobblestone_compressed:8";  -- Compressed dirt
    "ExtraUtilities:cobblestone_compressed:9";  -- Double dirt
    "ExtraUtilities:cobblestone_compressed:10";  -- Triple dirt
    "ExtraUtilities:cobblestone_compressed:11";  -- Quad dirt
    "minecraft:gravel:0";
    "ExtraUtilities:cobblestone_compressed:12";  -- Compressed Gravel
    "minecraft:sand:0";
    "ExtraUtilities:cobblestone_compressed:14";  -- Compressed sand
    "ExtraUtilities:cobblestone_compressed:15";  -- Double sand
    "minecraft:redstone:0";
    "ProjRed|Core:projectred.core.part:37";  -- Ruby
    "ProjRed|Core:projectred.core.part:38";  -- Sapphire
    "ProjRed|Core:projectred.core.part:0";  -- Peridot
    "ProjRed|Core:projectred.core.part:56"; -- Electrotine
    "Forestry:apatite:0";
    "Thaumcraft:ItemResource:6"; -- Amber
} )

local config = {
    ["craftingSlots"] = { 1; 2; 3; 5; 6; 7; 9; 10; 11 };
    ["outputSlot"] = 16;
    ["tempSlots"] = { 4; 8; 12; 13; 14; 15 };
    -- direction to drop non-matching items
    ["outDirection"] = "right";
    -- item names to drop down when filtering
    -- config.dropNames = nil
    -- item names to push to the non-default side
    -- config.sideNames = nil
    ["compact"] =  itemlist;
    ["interval"] = 30;
}

local slotCache = {}

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

function push(turn, turnBack, indices)
    if not indices or type(indices) ~= "table" then
        return false
    end

    turn()
    local result = true
    for i = 1, #indices do
        turtle.select(indices[i])
        result = pushTo() and result
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

function areSameType(a, b)
    if not a and not b then
        return true
    end

    if not a or not b then
        return false
    end

--    print("Comparing:")
--    printMetadata(a)
--    print ("To:")
--    printMetadata(b)
--    print()

    if a.name ~= b.name then
        return false
    end

    return a.damage == b.damage
end

function printMetadata(metadata)
   print(string.format("%s:%s (%s/%s) [%s]", metadata.name, tostring(metadata.damage), tostring(metadata.count), tostring(metadata.space) , tostring(metadata.indexFound)))
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
            if not itemData  then
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
    local result = nil
    while pullFunc() do
        result = turtle.getItemDetail()
        if areSameType(result, item) then
            return result
        end
        pushFunc()
    end
    return nil
end

function fillCraftingTable()

    print ("Filling the crafting table")

    local result = { }
    local matchingType
    local metadata
    local queuedItems = true

    repeat
        turtle.select(1)
        repeat until not pullFrom()

        for i = 1, 16 do
            if i > 1 then
                turtle.select(i)
            end

            metadata = turtle.getItemDetail()
            if not metadata then
                print("No metadata returned for slot "..i)
                queuedItems = false
                break
            end
            metadata.space = turtle.getItemSpace()

            -- Reject unfiltered items that have been added to the queue and stacks that are too
            -- small to compact if we're still looking for the first stack.
            if config.compact.contains(metadata) and (matchingType or metadata.count > 8)  then
                if matchingType then
                    -- If we have our stack return other types to the queue. Do the same if we have matching stacks, already.
                    if #result == 9 then
                      --  print("Pushing back item because the table is full")
                        pushBack()
                    elseif areSameType(matchingType, metadata) then
                     --   print("Found additional item in slot "..i)
                        metadata.foundIndex = i
                        table.insert(result, metadata)
                    else
                       -- print("Pushing through non-matching item from slot "..i)
                        pushTo()
                    end
                else
                    -- Found viable stack. Start counting.
                    matchingType = metadata
                    metadata.foundIndex = i
                    print("Will craft using items of the type in slot "..i)
                    table.insert(result, metadata)
                end
            else
                -- print("Pushing through a non-compacting item, or one that has too few items to compact")
                pushTo()
            end
        end
    until #result > 0 or not queuedItems

    if #result == 0 then
        return nil
    end

    if #result < 9 and queuedItems then
        for i = 1, #result do
            if result[i].foundIndex ~= i then
                turtle.select(result[i].foundIndex)
                turtle.transferTo(i)
                result[i].foundIndex = i
            end
        end
        turtle.select(#result + 1)
        while #result < 9 do
            if not pullFrom() then
                queuedItems = false
                break
            end
            metadata = turtle.getItemDetail()
            if areSameType(matchingType, metadata) then
                metadata.foundIndex = #result + 1
                table.insert(result, metadata)
                turtle.select(#result + 1)
            else
                pushTo()
            end
        end
    end

    for i = 1, #result do
        local currentIndex = result[i].foundIndex
        if not table.contains(config.craftingSlots, currentIndex) then
            local freeSlot
            for j = 1, #config.craftingSlots do
                local taken = false
                for k = 1, #result do
                    if result[k].foundIndex == config.craftingSlots[j] then
                        taken = true
                        break
                    end
                end
                if not taken then
                    freeSlot = config.craftingSlots[j]
                    break
                end
            end

            if not freeSlot then
                error("Error moving stacks to crafting grid.")
            end
            turtle.select(currentIndex)
            turtle.transferTo(freeSlot)
            result[i].foundIndex = freeSlot
        end
    end

    return result
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
    if (a.count >= level and b.count >= level) or (a.count <= level and b.count <= level) then
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

--    print("transfer to:"..toSlot.." from:"..fromSlot.." need: "..need.." level: "..level)
--    utilities.waitForEvent("key", 10, 32)
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

    -- The grid is already full
    if metadata[1] and metadata[1].space and (total == (metadata[1].count + metadata[1].space) * 9) then
        return true
    end

    local tMetadata = { }
    -- Initialize metadata for empty slots
    for i = 1, #config.craftingSlots do
        local found = false
        for j = 1, #metadata do
            if metadata[j].foundIndex == config.craftingSlots[i] then
                table.insert(tMetadata, metadata[j])
                found = true
                break
            end
        end
        if not found then
            local blank = { }
            blank.count = 0
            blank.foundIndex = config.craftingSlots[i]
            table.insert(tMetadata, blank)
        end
    end

    metadata = tMetadata

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
        local slotsFilled = fillCraftingTable()
        if not slotsFilled then
            break
        end
        -- get a count before empty metadata is added for empty slots
        slotsFilledCount = #slotsFilled

        if levelValues(slotsFilled) then
            turtle.select(config.outputSlot)
            print("crafting...")
            if turtle.craft() then
                print("success!")
                result = true
                pushTo()
            end
        end

        for i = 1, #config.craftingSlots do
            turtle.select(config.craftingSlots[i])
            pushTo()
        end
    -- When the slots are not full, the table filler will have tested and passed through
    -- all remaining items in the current bin looking for matches, so the pass is complete.
    until slotsFilledCount < 9
    return result
end

init()
while not done do
    filter()

    -- Run stacks back and forth between the two bins until no compact operations take place.
    repeat
        toggleInputOutputBins()
    until not compact()

    print(string.format("Waiting %d seconds before next cycle... ([space] to break)", config.interval))
    done = utilities.waitForEvent("key", config.interval, 57)
end


--endregion
--region *.lua
--Date

if not turtle then
    require("turtle")
end

if not utilities then
    dofile("utilities.lua")
end

local configFile
local args = { ... }

if #args > 0 then
    configFile = args[1]
end

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
    ["compact"] = {
        {
            ["name"] = "minecraft:dirt";
            ["damage"] = 0;
        };
        {
            ["name"] = "minecraft:cobblestone";
            ["damage"] = 0;
        };
        {
            ["name"] = "minecraft:gravel";
            ["damage"] = 0;
        };
        {
            ["name"] = "ExtraUtilities:cobblestone_compressed";
            ["damage"] = 0;
        };
        {
            ["name"] = "ExtraUtilities:cobblestone_compressed";
            ["damage"] = 1;
        };
        {
            ["name"] = "ExtraUtilities:cobblestone_compressed";
            ["damage"] = 2;
        };
        {
            ["name"] = "ExtraUtilities:cobblestone_compressed";
            ["damage"] = 3;
        };
        {
            ["name"] = "ExtraUtilities:cobblestone_compressed";
            ["damage"] = 8;
        };
        {
            ["name"] = "ExtraUtilities:cobblestone_compressed";
            ["damage"] = 9;
        };
        {
            ["name"] = "ExtraUtilities:cobblestone_compressed";
            ["damage"] = 10;
        };
        {
            ["name"] = "ExtraUtilities:cobblestone_compressed";
            ["damage"] = 11;
        };
        {
            ["name"] = "ExtraUtilities:cobblestone_compressed";
            ["damage"] = 12;
        };
        {
            ["name"] = "ExtraUtilities:cobblestone_compressed";
            ["damage"] = 13;
        };
    };
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

function contains(t, item)
    if not t or not item then
        return false
    end

    for i = 1, #t do
        if areSameType(t[i], item) then
--            print("matched")
            return true
        end
    end
    return false
end

function printMetadata(metadata)
--    print(string.format("{ count = %s, name = %s, damage = %s}", tostring(metadata.count), metadata.name, tostring(metadata.damage)))
end

function transfer(toSlot, from, to, amount, leave)

    if not leave then
        leave = 0
    end

    local have = from.count - leave

    if have <= 0 then
        return false
    end

    transferAmount = amount > have and have or amount

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
            elseif contains(config.compact, itemData) then
                pushTo()
            elseif contains(config.dropNames, itemData) then
                turtle.dropDown()
            else
                if contains(config.sideNames, itemData) then
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
            if contains(config.compact, metadata) and (matchingType or metadata.count > 8)  then
                if matchingType then
                    -- If we have our stack return other types to the queue. Do the same if we have matching stacks, already.
                    if #result == 9 then
                        print("Pushing back item because the table is full")
                        pushBack()
                    elseif areSameType(matchingType, metadata) then
                        print("Found additional item in slot "..i)
                        metadata.foundIndex = i
                        table.insert(result, metadata)
                    else
                        print("Pushing through non-matching item from slot "..i)
                        pushTo()
                    end
                else
                    -- Found viable stack. Start counting.
                    matchingType = metadata
                    metadata.foundIndex = i
                    print("Using item in slot "..i.." as master")
                    table.insert(result, metadata)
                end
            else
                print("Pushing through a non-compacting item, or one that has too few items to compact")
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

    local a = metadata[indexA]
    local b = metadata[indexB]

    if (a.count >= level and b.count >= level) or (a.count <= level and b.count <= level) then
        return
    end

    local to, from, have, need

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

    turtle.select(fromSlot)

    transfer(toSlot, from, to, (level - to.count), level)
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

    -- Initialize metadata for empty slots
    for i = 1, #config.craftingSlots do
        if not metadata[i] then
          metadata[i] = { }
          metadata[i].count = 0
        end
    end

    local split = math.floor(total / 9)
    print(string.format("Split = %d", split))

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
            if turtle.craft() then
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
    until #slotsFilledCount < 9
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
    done = utilities.waitForEvent("key", config.interval, 32)
end


--endregion
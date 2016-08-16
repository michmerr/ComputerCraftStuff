--region *.lua
--Date

if not turtle then
    require("turtle")
end
require("utilities")

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
        ["interval"] = 30;
    }
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

function transfer(from, to, amount, leave)

    if not leave then
        leave = 0
    end

    local have = from.count - leave

    if have <= 0 then
        return false
    end

    transfer = amount > have and have or amount

    turtle.transferTo(toSlot, transfer)

    from.count = from.count - transfer
    to.count = to.count + transfer

end

function filter()
    local keep, itemData, noneLeft

    print "Filtering out items that will not be kept and compacted."

    repeat
        pushSide = { }
        pushDefault = { }

        for i = 1, 16 do
            keep = false
            turtle.select(i)
            repeat
                if pullFrom() then
                    itemData = turtle.getItemDetail()
                    if contains(config.compact, itemData) then
                        pushTo()
                    elseif contains(config.dropNames, itemData) then
                        turtle.dropDown()
                    else
                        if contains(config.sideNames, itemData) then
                            table.insert(pushSide, i)
                        else
                            table.insert(pushDefault, i)
                        end
                        keep = true
                    end
                else
                    i = 16
                    keep = true
                end
            until keep
        end

        if #pushSide > 0 then
            push(sideTurn, defaultTurn, pushSide)
        end

        if #pushDefault > 0 then
            push(defaultTurn, sideTurn, pushDefault)
        end

    until #pushSide + #pushDefault == 0
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

    turtle.select(config.craftingSlots[1])
    if not pullFrom() then
        return nil
    end

    local result = { }
    local metadata = turtle.getItemDetail()
    metadata.space = turtle.getItemSpace()
    table.insert(result, metadata)
    local currentType = metadata
    for i = 2, #config.craftingSlots do
        turtle.select(config.craftingSlots[i])
        repeat
            metadata = getSameItem(pullFrom, pushTo, currentType)
            if not metadata then
                break
            end
            metadata.space = turtle.getItemSpace()
            if result[i-1].space > 0 then
                local transfer = result[i-1].space
                if transfer > metadata.count then
                    transfer = metadata.count
                end
                transfer(metadata, result[i-1], result[i-1].space)
            end
        until metadata.count > 0
        if not metadata then
            break
        end
        table.insert(result, metadata)
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

    local to, from, have, need, transfer

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
    transfer(from, to, level - to.count, level)
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
    if metadata[1].space and (total == (metadata[1].count + metadata[1].space) * 9) then
        return true
    end

    -- Initialize metadata for empty slots
    for i = 0, #config.craftingSlots do
        if not metadata[i] then
          metadata[i] = { }
          metadata[i].count = 0
        end
    end

    local split = math.floor(total / 9)
    print(string.format("Split = %d", split))

    for i = 1, #config.craftingSlots do
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

-- return -1 if there are no more items in the queue;
-- 0 if there are items waiting, but the current compact was a noop,
-- 1 if a compact was performed
function compact()
    local slotsFilled = fillCraftingTable()
    if not slotsFilled then
        return -1
    end

    local result = -1
    local pushRemainder = pushTo

    if levelValues(slotsFilled) then
        turtle.select(config.outputSlot)
        if turtle.craft() then
            result = 1
            pushBack()
        end
    else
        -- if there weren't enough to create a single block, push back to origin
        -- so it doesn't get pulled in on the next flip.
        pushRemainder = pushBack
    end

    for i = 1, #config.craftingSlots do
        turtle.select(config.craftingSlots[i])
        pushRemainder()
    end

    return result
end

init()
while not done do
    filter()
    while compact() > -1 do
        toggleInputOutputBins()
    end
    toggleInputOutputBins()
    print(string.format("Waiting %d seconds before next cycle...", config.interval))
    done = utilities.waitForEvent("terminate", config.interval)
end


--endregion
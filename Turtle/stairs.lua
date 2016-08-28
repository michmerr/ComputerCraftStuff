--region *.lua
--Date

if not turtle then
    require("turtle")
end

local x = 0
local y = 0
local z = 0
local xDir = 0
local zDir = 1

function selectMaterialSlot(lower, upper, types)
    if turtle.getSelectedSlot() >= lower and turtle.getSelectedSlot() <= upper and turtle.getItemCount() > 0 then
        return true
    end
--TODO: check against list of acceptable item types

    for i = lower, upper do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            return true
        end
    end

    return false
end

local function digUntil(digFunc, detectFunc)
    if not detectFunc() then
        return false
    end

    local result = digFunc()
    while detectFunc() do
        os.sleep(0.5)
        result = digFunc()
    end
    return result
end

local function dig()
  return digUntil(turtle.dig, turtle.detect)
end

local function digUp()
  return digUntil(turtle.digUp, turtle.detectUp)
end

local function digDown()
  return digUntil(turtle.digDown, turtle.detectDown)
end


local function move(detectFunc, digFunc, moveFunc, attackFunc, suckFunc)
    if detectFunc() then
        digUntil(digFunc, detectFunc)
    end

    -- I feel like I'm encouraging some twisted behavior right here.
    if not moveFunc() then
        while attackFunc() do
            suckFunc()
        end
        if not moveFunc() then
            return false
        end
    end
end

local function down()
    local result = move(turtle.detectDown, turtle.digDown, turtle.down, turtle.attackDown, turtle.suckDown)
    if result then
        y = y - 1
    end

    return result

end

local function up()
    local result = move(turtle.detectUp, turtle.digUp, turtle.up, turtle.attackUp, turtle.suckUp)
    if result then
        y = y + 1
    end
    return result
end

local function forward()
    local result = move(turtle.detect, turtle.dig, turtle.forward, turtle.attack, turtle.suck)
    if result then
        x = x + xDir
        z = z + zDir
    end
    return result
end

-- -1 out of materials, 0 place failed, 1 place succeeded, 2 block already occupied
local function place(placeFunc, detectFunc, attackFunc, slotLow, slotHigh, materialType)
    if not selectMaterialSlot(slotLow, slotHigh, materialType) then
        return -1
    end

    if detectFunc() then
        return 2
    end
    if not placeFunc() then
        if attackFunc() then
            repeat
                print("Mob blocking placement")
            until attackFunc()
            print("Mob cleared")
            if not placeFunc() then
                return 0
            end
        end
        return 0
    end
    return 1
end

local function placeUp(slotLow, slotHig, materialType)
    return place(turtle.placeUp, turtle.detectUp, turtle.attackUp, slotLow, slotHig, materialType)
end

local function placeDown(slotLow, slotHig, materialType)
    return place(turtle.placeDown, turtle.detectDown, turtle.attackDown, slotLow, slotHig, materialType)
end

local function placeForward(slotLow, slotHig, materialType)
    return place(turtle.place, turtle.detect, turtle.attack, slotLow, slotHig, materialType)
end

local function turnRight()
    turtle.turnRight()
    local _zDir = xDir * - 1
    xDir = zDir
    zDir = _zDir
end

local function turnLeft()
    turtle.turnLeft()
    local _zDir = xDir
    xDir = zDir * -1
    zDir = _zDir
end


local function changeDirection(turn)
    if turn == turnLeft then
        return  turnRight
    end
    return turnLeft
end

function resupply()
    -- this could get tricky, since we can't count on there being any sort of
    -- clear vertical return route as there is in an excavation. This problem means
    -- code to walk up and down the stairs as part of the navigation.

    -- or just hang out until a human comes to do the resupply

    print("I'm out of stair stuff. Put it in slots 2-14!")
    repeat
        notification = { os.pullEvent() }
        event, p1 = table.unpack(notification)
        if event == "key" and p1 == 57 then
            exit()
        end
    until event == "turtle_inventory" and selectMaterialSlot(2, 14)
    print("Waiting 10 seconds for additional stuff...")
    os.sleep(10)
    print("Go time!")
end

function simpleStepTraversal(turn, above, width, depth, stairsUp, action, turnAtStart)
    if turnAtStart then
      turn = changeDirection(turn)
      turn()
      if depth == 1 then
        turn()
      end
    end
    for j =1, depth do
        action(1, turn, above, stairsUp)
        -- save the cost of turning for when stairs are wider than one block
        if (width > 1) then
            turn()
            turn = changeDirection(turn)
            for i = 2, width do
                forward()
                action(i, turn, above, stairsUp)
            end
        end
        if j < depth then
          turn()
          forward()
        end
    end
    return turn
end

-- returns 0 for failure, 1 for success, 2 if stair was already there
function layTread(iteration, turn, above, stairsUp)
    local pr = placeDown(2, 14)
    if pr < 0 then
        resupply()
        pr = placeDown(2, 14)
    end
    -- this *should* only be possible on the first placement, since subsequent blocks will attach the the first
    if pr == 0 then
        down()
        if stairsUp then
            -- this should always work since it would extend the previous step
            pr = placeDown(2, 14)
        else
            turn()
            -- on the first iteration, we are facing away from the previous step
            if (iteration == 1) then
                turn()
            end
            -- this should always work since it would attach to the bottom of the previous step
            pr = placeForward(2, 14)
            if (iteration == 1) then
                turn()
                turn()
            else
                changeDirection(turn)()
            end
        end
        if (pr < 1) then
            print(string.format("error anchoring to previous step at %d, %d, %d (relative)", x, y, z))
        end
        up()
        pr = placeDown(2, 14)
        if pr < 0 then
            resupply()
            pr = placeDown(2, 14)
        end
        if (pr < 1) then
            print(string.format("error placing step at %d, %d, %d (relative)", x, y, z))
        end
    end
    return pr
end

function clearAirspace(iteration, turn, above, stairsUp)
    digDown()
    digUp()
end

function runIntervalActions(intervalActions, count, currentTurn, startTurn, above, facingWall)
    if intervalActions then
        for action in intervalActions do
            action(count, currentTurn, startTurn, above, facingWall)
        end
    end
end

function simpleStep(turn, above, startTurn, width, depth, stairsUp, intervalActions, count)

    if not count then
        count = 0
    end

    count = count + 1

    local firstPass, secondPass

    if stairsUp then
        up()
    end

    forward()

    if not stairsUp then
        down()
    end

    runIntervalActions(intervalActions, count, turn, above, startTurn, above, false)

    local facingSide = width > 1
    if above then
        turn = simpleStepTraversal(turn, above, width, depth, stairsUp, clearAirspace, false)
        runIntervalActions(intervalActions, count, turn, above, startTurn, true, facingSide)
        down()
        down()
        runIntervalActions(intervalActions, count, turn, above, startTurn, false, facingSide)
        turn = simpleStepTraversal(turn, above, width, depth, stairsUp, layTread, true)
    else
        turn = simpleStepTraversal(turn, above, width, depth, stairsUp, layTread, false)
        runIntervalActions(intervalActions, count, turn, above, startTurn, false, facingSide)
        up()
        up()
        runIntervalActions(intervalActions, count, turn, above, startTurn, true, facingSide)
        turn = simpleStepTraversal(turn, above, width, depth, stairsUp, clearAirspace, true)
    end

    runIntervalActions(intervalActions, count, turn, above, startTurn, not above, false)

    return turn, not above, count
end

function simpleFlight(turn, above, startTurn, length, width, depth, stairsUp, intervalActions, count)
    -- Assumes a start position facing the direction to create the flight
    -- of stairs, immediately in front of the first step, and next to the anchor
    -- wall. Initial turn should be away from the anchoring wall. This will be
    -- passed to intervalAction functions so they can orient themselves.

    local stepCount = math.floor(length / depth)
    local remainderDepth = length % depth

    local useDepth = depth
    for i = 1, stepCount do
        if i == stepCount and remainderDepth > 0 then
            -- assume that a landing or other continuation makes a shallow final step ok.
            useDepth = remainderDepth
        end
        turn, above, count = simpleStep(turn, above, startTurn, width, useDepth, stairsUp, intervalActions, count)
    end

    return turn, above, count
end

function turnCorner(turn, initialTurn, centerAnchor, treadWidth)
    if centerAnchor then
        changeDirection(initialTurn())()
        if initialTurn ~= turn then
            for j = 2, treadWidth do
                forward()
            end
        else
            turn = changeDirection(turn)
        end
    else
        initialTurn()
        if initialTurn == turn then
            for j = 2, treadWidth do
                forward()
            end
        else
            turn = initialTurn
        end
    end
    return turn
end

function simpleSpiralSide(turn, above, initialTurn, count, limit, flightLength, treadWidth, treadDepth, stairsUp, intervalActions)
   local steps = math.ceil(flightLength / treadDepth)

    --stairs
    if steps < limit - count then
        turn, above, count = simpleFlight(turn, above, initialTurn, flightLength, treadWidth, treadDepth, stairsUp, intervalActions, count)

        if count < limit then
            --landing
            turn, above, count = simpleStep(turn, above, initialTurn, treadWidth, treadWidth, stairsUp, intervalActions, count)
            turn = turnCorner(turn, initialTurn, centerAnchor, treadWidth)
        end
    else
        turn, above, count = simpleFlight(turn, above, initialTurn, (limit - count) * treadDepth, treadWidth, treadDepth, stairsUp, intervalActions, count)
    end

    return turn, above, count
end

-- Starting in front of the first step, immediately adjacent to the anchor wall.
-- Positive height value for stairs up, negative for down.
-- Table of interval actions that will be called as functions with the step count, current turn, above, and initial turn after each step.
function simpleSpiralStairs(height, clockwise, centerAnchor, anchorWallLength, anchorWallWidth, treadDepth, treadWidth, intervalActions)
    local flightLengthZ = anchorWallLength
    local flightLengthX = anchorWallWidth
    local count = 0
    local totalCount = math.abs(height)
    if not centerAnchor then
        flightLengthZ = flightLengthZ - (2 * treadWidth)
        flightLengthX = flightLengthX - (2 * treadWidth)
    end

    local turn, above, initialTurn
    if (clockwise and centerAnchor) or (not clockwise and not centerAnchor) then
        turn = turnLeft
    else
        turn = turnRight
    end
    initialTurn = turn

    if not centerAnchor then
        -- flush landing
        up()
        turn, above, count = simpleStep(turn, above, initialTurn, treadWidth, treadWidth, false, intervalActions, count)
    end

    while count < totalCount do
        turn, above, count = simpleSpiralSide(turn, above, initialTurn, count, totalCount, flightLengthZ, treadWidth, treadDepth, height > 0, intervalActions)
        if count == totalCount then
            break
        end

        turn, above, count = simpleSpiralSide(turn, above, initialTurn, count, totalCount, flightLengthX, treadWidth, treadDepth, height > 0, intervalActions)
        if count == totalCount then
            break
        end

        turn, above, count = simpleSpiralSide(turn, above, initialTurn, count, totalCount, flightLengthZ, treadWidth, treadDepth, height > 0, intervalActions)
        if count == totalCount then
            break
        end

        turn, above, count = simpleSpiralSide(turn, above, initialTurn, count, totalCount, flightLengthX, treadWidth, treadDepth, height > 0, intervalActions)
    end
end

function placeTorches(stairInterval, high)

    return function(count, turn, startTurn, above, facingWall)
        if count % interval ~= 0
            or turn ~= startTurn
            or high and not above
            or above and not high then
            return true
        end

        if not facingWall then
            changeDirection(turn)()
        end

        local result = (not turtle.detect() or placeForward(2, 14)) and placeForward(16, 16)

        if not facingWall then
            turn()
        end

        return result
    end
end

function placeRailings(stairInterval)

    return function(count, turn, startTurn, above, facingWall)
        if above or count % interval ~= 0 or turn == startTurn then
            return true
        end

        if not facingWall then
            changeDirection(turn)()
        end

        if turtle.detect() then
            return true
        end

        forward()
        placeDown(2, 14)
        turtle.back()
        local result = placeForward(15,15)

        if not facingWall then
            turn()
        end

        return result
    end
end


--endregion
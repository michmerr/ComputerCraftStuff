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
    if turtle.getSelectedSlot() >= lower and turtle.getSelectedSlot <= upper and turtle.getItemCount() > 0 then
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

local function move(detectFunc, digFunc, moveFunc, attackFunc, suckFunc)
    if detectFunc() then
        digUntil(digFunc, detectFunc)
    end

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
local function place(placeFunc, detectFunc, attackFunc)
    if not selectMaterialSlot(2, 14) then
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

local function placeUp()
    return place(turtle.placeUp, turtle.detectUp, turtle.attackUp)
end

local function placeDown()
    return place(turtle.placeDown, turtle.detectDown, turtle.attackDown)
end

local function placeForward()
    return place(turtle.place, turtle.detect, turtle.attack)
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

function lateral(turn, width, shouldDigUp, shouldPlaceDown, shouldDigDown)

    turn()
    turn = changeDirection(turn)
    for j = 2, width do
        forward()
        if shouldDigUp then
            digUntil(turtle.digUp, turtle.detectUp)
        end
        if shouldPlaceDown then
            if not place() then
                return false
            end
        elseif shouldDigDown then
            if not turtle.detectDown() then
                turtle.digDown()
            end
        end
    end
    turn()
    return turn
end

local function stepLayer(turn, width, depth, ceiling, c)
    local digUp = true
    local digDown = true
    local placeDown = false

    if c == 1 then
        digDown = false
        placeDown = true
    elseif ceiling - c > 1 then
        up()
    elseif ceiling == 1 then
        digDown = false
    else
        digUp = false
    end

    for i = 1, depth do
        if placeDown then
            if not place() then
                return false
            end
        elseif digDown then
            if turtle.detectDown() then
                turtle.digDown()
            end
        end

        if digUp then
            digUntil(turtle.digUp, turtle.detectUp)
        end
        if width > 1 then
            turn = lateral(turn, width, digUp, placeDown, digDown)
        end
        if i ~= depth then
            forward()
        end
    end
    return turn
end

function resupply()




end

function simpleStepTraversal(turn, width, depth, up, action)
    for j =1, depth do
        for i = 1, width do
            -- Our first move is forward into the current depth,
            -- so the first thing we need to do before the second
            -- width is turn to face down that axis. If the width is
            -- only one, we save the time it takes to turn and turn
            -- back.
            if i == 2 then
                turn()
                turn = changeDirection(turn)
            end
            forward()
            action(i, turn, up)
        end
        -- turn back to face forward after a > 1 width traversal
        if width > 1 then
            turn()
        end
    end

end

-- returns 0 for failure, 1 for success, 2 if stair was already there
function layTread(iteration, turn, up)
    local pr = placeDown()
    if pr < 0 then
        resupply()
        pr = placeDown()
    end
    -- this *should* only be possible on the first placement, since subsequent blocks will attach the the first
    if pr == 0 then
        down()
        if up then
            -- this should always work since it would extend the previous step
            pr = placeDown()
        else
            turn()
            -- on the first iteration, we are facing away from the previous step
            if (iteration == 1) then
                turn()
            end
            -- this should always work since it would attach to the bottom of the previous step
            pr = placeForward()
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
        pr = placeDown()
        if pr < 0 then
            resupply()
            pr = placeDown()
        end
        if (pr < 1) then
            print(string.format("error placing step at %d, %d, %d (relative)", x, y, z))
        end
    end
    return pr
end

function clearAirspace(iteration, turn, up)
    digDown()
    digUp()
end

function simpleStep(turn, width, depth, up, intervalActions, count)

    if not count then
        count = 0
    end

    if (up) then
        up()
        up()
    end

    -- clear the airspace
    turn = simpleStepTraversal(turn, width, depth, up, clearAirspace)

    -- land on desired step
    down()
    -- back up to edge of previous step
    for i = 2, depth do
        turtle.back()
    end

    -- laydown the tread
    turn = simpleStepTraversal(turn, width, depth, up, layTread)

    count = count + 1
    if intervalActions then
        for action in intervalActions do
            action(count, turn, startTurn)
        end
    end

    return turn, count
end

function simpleFlight(turn, length, width, depth, up, intervalActions, count)
    -- Assumes a start position facing the direction to create the flight
    -- of stairs, immediately in front of the first step, and next to the anchor
    -- wall. Initial turn should be away from the anchoring wall. This will be
    -- passed to intervalAction functions so they can orient themselves.
    local startTurn = turn

    local stepCount = math.floor(length / depth)
    local remainderDepth = length % depth

    local useDepth = depth
    for i = 1, stepCount do
        if i == stepCount and remainderDepth > 0 then
            -- assume that a landing or other continuation makes a shallow final step ok.
            useDepth = remainderDepth
        end
        turn, count = simpleStep(turn, width, useDepth, up, intervalActions, count)
    end

    return turn, count
end

function turnCorner(turn, initialTurn, centerAnchor)
    if centerAnchor then
        changeDirection(initialTurn())()
        if initialTurn ~= turn then
            for j = 1, treadWidth do
                forward()
            end
        else
            turn = changeDirection(turn)
        end
    else
        initialTurn()
        if initialTurn == turn then
            for j = 1, treadWidth do
                forward()
            end
        else
            turn = initialTurn()
        end
    end
    return turn
end

function simpleSpiralSide(turn, count, limit, flightLength, treadWidth, treadDepth, up, intervalActions)
   local steps = math.ceil(flightLength / treadDepth)

    --stairs
    if steps < limit - count then
        turn, count = simpleFlight(turn, flightLength, treadWidth, treadDepth, up, intervalActions, count)

        if count < limit then
            --landing
            turn, count = simpleStep(turn, treadWidth, treadWidth, height > 1, intervalActions, count)
            turn = turnCorner(turn, initialTurn, centerAnchor)
        end
    else
        turn, count = simpleFlight(turn, (limit - count) * treadDepth, treadWidth, treadDepth, up, intervalActions, count)
    end

    return turn, count
end

-- Starting in front of the first step, immediately adjacent to the anchor wall.
-- Positive height value for stairs up, negative for down.
-- Table of interval actions that will be called as functions with the step count, current turn, and initial turn after each step.
function simpleSpiralStairs(height, clockwise, centerAnchor, anchorWallLength, anchorWallWidth, treadDepth, treadWidth, intervalActions)
    local flightLengthZ = anchorWallLength
    local flightLengthX = anchorWallWidth
    local count = 0
    local totalCount = math.abs(height)

    if not centerAnchor then
        flightLengthZ = flightLengthZ - (2 * treadWidth)
        flightLengthX = flightLengthX - (2 * treadWidth)
    end

    local turn, initialTurn
    if (clockwise and centerAnchor) or (not clockwise and not centerAnchor) then
        turn = turnLeft()
    else
        turn = turnRight()
    end
    initialTurn = turn

    if not centerAnchor then
        -- flush landing
        up()
        turn, count = simpleStep(turn, treadWidth, treadWidth, false, intervalActions, count)
    end

    while count < totalCount do
        turn, count = simpleSpiralSide(turn, count, totalCount, flightLengthZ, treadWidth, treadDepth, height > 0, intervalActions)
        if count == totalCount then
            break
        end

        turn, count = simpleSpiralSide(turn, count, totalCount, flightLengthX, treadWidth, treadDepth, height > 0, intervalActions)
        if count == totalCount then
            break
        end

        turn, count = simpleSpiralSide(turn, count, totalCount, flightLengthZ, treadWidth, treadDepth, height > 0, intervalActions)
        if count == totalCount then
            break
        end

        turn, count = simpleSpiralSide(turn, count, totalCount, flightLengthX, treadWidth, treadDepth, height > 0, intervalActions)
    end
end

function step(turn, width, depth, ceiling)

    for c = 1, ceiling + 1, 3 do
        turn = stepLayer(turn, width, depth, ceiling, c)

        for i = 1, math.min(3, ceiling - c - 1) do
            up()
        end
    end

    return turn
end

function placeTorch(turn)


end

function wall(length, turn, width, depth, ceiling, torchInterval)
    down()
    forward()
    for i = width, length, width do
        turn = step(turn, width, depth, ceiling)
        torchWhen = torchWhen - 1
        if torchWhen == 0 then
            placeTorch(turn)
        end
    end
    down()

end

function stairsDown(zLength, xWidth, turn, width, depth, ceiling, torchInterval)
    local initialTurn = turn
    local torchWhen = torchInterval
    forward()
    down()
    turn = step(turn, width, depth, ceiling)
    --if x > 0 then

    while y + depth > 0 do
        wall(zLength, turn, width, depth, ceiling, torchInterval)
        initialTurn()
        for i = math.abs(x), width do
            forward()
        end
        wall(xLength, initialTurn, width, depth, ceiling, torchInterval)
        initialTurn()
        for i = math.abs(z), zLength - width, -1 do
            forward()
        end
        wall(zLength, turn, width, depth, ceiling, torchInterval)
        initialTurn()
        for i = math.abs(x), xLength - width, -1 do
            forward()
        end
        wall(xLength, initialTurn, width, depth, ceiling, torchInterval)
        initialTurn()
        for i = math.abs(z), width do
            forward()
        end
    end
end







--endregion

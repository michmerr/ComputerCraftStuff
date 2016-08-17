--region *.lua
--Date

local function loadDependency(dep)
    if not _G[dep] then
        if require then
            require(dep)
        else
            dofile(dep..".lua")
        end
    end
end

loadDependency("terp")
loadDependency("location")
loadDependency("terpRefuel")

function terpCommands.createDefault()
    local result = terp.create()
    location.decorate(result)
    terpRefuel.decorate(result, true)
    local commands = terpCommands.create(result)
    return result
end

function terpCommands.decorate(terpTarget)

    local self = {}

    function self.digLayer(width, length, changeDepth, digPrevious, digNext, turn)

        for j = 1, width - 1 do
            for k = 1, length do
                if not terpTarget.forward() then
                    return false
                end
                if digPrevious then
                    digPrevious()
                end
                if digNext then
                    digNext()
                end
            end
            turn()
            if not terpTarget.forward() then
                return false
            end
            turn()
            if turn == terpTarget.turnLeft then
                turn = terpTarget.turnRight
            else
                turn = terpTarget.turnLeft
            end
        end
        if not terpTarget.forward(length) then
            return false
        end
        turn()
    end

    local function getMoves(length, width, vertical)
        local changeVertical = terpTarget.up
        local digPrevious = terpTarget.digDown
        local digNext = terpTarget.digUp
        local firstTurn = terpTarget.turnRight

        if vertical < 0 then
            changeVertical = terpTarget.down
            digPrevious = terpTarget.digUp
            digNext = terpTarget.digDown
        end

        if length < 0 then
            terpTarget.turnLeft()
            terpTarget.turnLeft()
            if width > 0 then
                firstTurn = terpTarget.left
            end
        elseif width < 0 then
            firstTurn = terpTarget.left
        end

        return firstTurn, changeVertical, digPrevious, digNext
    end

    function self.offset(lateral, forward, vertical)
        if not lateral and not forward and not vertical then
            return true
        end

        if lateral then
            if lateral > 0 then
                if not terpTarget.stepLeft(lateral) then
                    return false
                end
            elseif (lateral < 0) then
                if not terpTarget.stepRight(lateral * -1) then
                    return false
                end
            end
        end

        if forward then
            if forward > 0 then
                if not terpTarget.forward(forward) then
                    return false
                end
            elseif (forward < 0) then
                if not terpTarget.reverse(forward * -1) then
                    return false
                end
            end
        end

        if vertical then
            if vertical > 0 then
                if not terpTarget.up(vertical) then
                    return false
                end
            elseif (forward < 0) then
                if not terpTarget.down(vertical * -1) then
                    return false
                end
            end
        end

        return true
    end

    function self.tunnel(length, width, height, lateral_offset, horizontal_offset, vertical_offset)
        if not length or not width or not height then
            error("length. width, and height values cannot be nil")
        end

        local offset = math.floor(width / 2)

        if not self.offset(lateral_offset - offset, horizontal_offset, vertical_offset) then
            return false
        end

        if not depth or depth == 0 then
            depth = 256
        end

        local firstTurn, changeDepth, digPrevious, digNext = getMoves(length, width, height)

        height = math.abs(height)
        length = math.abs(length)
        width = math.abs(width)

        local level = 0
        local pivot = false
        local w = width
        local l = length

        if not terpInstance.forward() then
            return false
        end

        while level < height do
            -- can't/shouldn't dig any farther, dig this single layer and return.
            if level == height or not changeDepth() then
                digPrevious = nil
                digNext = nil
                level = height
            else
                level = level + 1
            end

            -- if this is the hard-deck or target height, dig this layer and the previous and return.
            if level == height or not digNext() then
                digNext = nil
            end

            if pivot then
                w = length
                l = width
            else
                w = width
                l = length
            end

            if not self.digLayer(w, l, changeDepth, digPrevious, digNext, firstTurn) then
                return false
            end

            if w % 2 == 1 then
                if firstTurn == terpTarget.turnRight then
                    firstTurn = terpTarget.turnLeft
                else
                    firstTurn = terpTarget.turnRight
                end
            end
            pivot = not pivot
        end
        return true
    end

    function self.hole(length, width, depth, lateral_offset, horizontal_offset, vertical_offset)

        if not length or not width then
            error("length and width values cannot be nil")
        end

        if not self.offset(lateral_offset, horizontal_offset, vertical_offset) then
            return false
        end

        if not depth or depth == 0 then
            depth = 256
        end

        local firstTurn, changeDepth, digPrevious, digNext = getMoves(length, width, depth * -1)

        depth = math.abs(depth)
        length = math.abs(length)
        width = math.abs(width)

        local level = 0
        local pivot = false
        local w = width
        local l = length

        while level < depth do
            -- position is currently above/below the next layer
            if not changeDepth() then
                break
            end
            level = level + 1

            -- can't/shouldn't dig any farther, dig this single layer and return.
            if level == depth or not changeDepth() then
                digPrevious = nil
                digNext = nil
                level = depth
            else
                level = level + 1
            end

            -- if this is the hard-deck or target depth, dig this layer and the previous and return.
            if level == depth or not digNext() then
                digNext = nil
            end

            if pivot then
                w = length
                l = width
            else
                w = width
                l = length
            end

            if not self.digLayer(w, l, changeDepth, digPrevious, digNext, firstTurn) then
                return false
            end

            if w % 2 == 1 then
                if firstTurn == terpTarget.turnRight then
                    firstTurn = terpTarget.turnLeft
                else
                    firstTurn = terpTarget.turnRight
                end
            end
            pivot = not pivot
        end
    end

    function self.sealSides(length, width, depth, lateral_offset, horizontal_offset, vertical_offset)

    end

    function self.sealFlat(length, width, depth, lateral_offset, horizontal_offset, vertical_offset)

    end

    function self.seal(length, width, depth, lateral_offset, horizontal_offset, vertical_offset)

        if not self.offset(lateral_offset, horizontal_offset, vertical_offset) then
            return false
        end

        if not depth or depth == 0 then
            depth = 256
        end
    end

    function selectMaterialSlot(lower, upper, types)

    --TODO: check against list of acceptable item types

        for i = lower, upper do
            self.select(i)
            if self.getItemCount() > 0 then
                return i
            end
        end

        return nil
    end

    function readyToPlace(lower, upper, types)
        if self.getItemCount() > 0 then
            return self.getSelectedSlot()
        end

        return selectMaterialSlot(lower, upper, types)
    end

    function placeDown(lower, upper, types)
        local slot = readyToPlace(lower, upper, types)
        if slot and not self.detectDown() then
           self.placeDown()
        end
        return slot
    end

    function stepDown(stairWidth, stairDepth, clearForward, back)
        local turn = self.turnRight
        for w = 1, stairWidth do
            if w > 1 then
                self.forward()
                turn()
                if turn == self.turnRight then
                    turn = self.turnLeft
                else
                    turn = self.turnRight
                end
            end
            if not back or clearForward > 1 then
                for i = 1, stairDepth do
                    if i > 1 then
                        self.forward()
                    end
                    if not back then
                        if not placeDown(2,14) then
                            return nil
                        end
                        self.digUp()
                    end
                end
            end
            if clearForward > 0 then
                for i = 1, stairDepth do
                    self.forward()
                    self.digDown()
                    if not back then
                        self.digUp()
                    end
                end
            end
            if back or clearForward > 1 then
                for i = 1, stairDepth do
                    self.forward()
                    if back then
                        if not placeDown(2,14) then
                            return nil
                        end
                        self.digUp()
                    else
                        self.digDown()
                    end
                end
            end
            turn()
            if w == stairWidth then
                turn()
            end
            back = not back
        end
        return back
    end

    function stairsDown(length, width, depth, anchorSide, stairWidth, stairDepth, torchInterval)
        if not anchorSide then
            anchorSide = 0
        end

        local back = false
        while (depth == 0 or depth - self.getLocation.y > 0) do
            for zDir = 1, length - stairDepth, stairDepth do
                back = stepDown(stairWidth, stairDepth, length - zDir, back)
                if back == nil then
                    return false
                end
            end
            if back then
                self.turnLeft()
            else
                self.forward(stairDepth)
                self.turnRight()
            end

            if self.getLocation.x > 0 then
                self.back(self.getLocation.x)
            end

            back = false

            for xDir = 1, width, stairDepth do
                back = stepDown(stairWidth, stairDepth, width - xDir, back)
                if back == nil then
                    return false
                end
            end

            if back then
                self.turnLeft()
            else
                self.forward(stairDepth)
                self.turnRight()
            end

            if self.getLocation.x > 0 then
                self.back(self.getLocation.x)
            end

            back = false

            for zDir = length, stairDepth, stairDepth * -1 do
                back = stepDown(stairWidth, stairDepth, zDir, back)
                if back == nil then
                    return false
                end
            end

            if back then
                self.turnLeft()
            else
                self.forward(stairDepth)
                self.turnRight()
            end

            if self.getLocation.x > 0 then
                self.back(self.getLocation.x)
            end

            back = false

            for xDir = width, stairDepth, stairDepth * -1 do
                back = stepDown(stairWidth, stairDepth, xDir, back)
                if back == nil then
                    return false
                end
            end
        end
    end

    function self.stairs(length, width, depth, anchorSide, stairWidth, stairDepth, torchInterval, lateral_offset, horizontal_offset, vertical_offset)

        local direction, verticalMove, materialSlot, torchSlot

        if not length or not width then
            print("Will try to determine dimensions by measuring the edge of the opening")
        end

        if not depth or depth == 0 then
            depth = 0
            print("Will continue until a flat surface is encountered")
        end

        if not stairWidth then
            stairWidth = 2
            print("Defaulting to stair width of "..stairWidth)
        end

        if not stairDepth then
            stairDepth = 1
            print("Defaulting to stair tread depth of "..stairDepth)
        end

        if not self.offset(lateral_offset, horizontal_offset, vertical_offset) then
            return false
        end

        materialSlot = selectMaterialSlot(2, 14)
        if not materialSlot then
            error("Materials needed in slots 2-14")
        end

        if torchInterval and torchInterval > 0 then
            torchSlot = selectMaterialSlot(15,16)
            if not torchSlot then
                error("To set torches, you must place torches in slots 15 and/or 16.")
            end
        end

        if depth >= 0 then
            direction = 1
            verticalMove = self.down
        else
            direction = -1
            verticalMove = self.up
        end

        length, width, direction, adjust_lateral, adjust_horizontal, adjust_vertical =
            self.findDimensions(length, width, direction)

        self.offset(adjust_lateral, adjust_horizontal, adjust_vertical)
        self.select(materialSlot)

        if depth >= 0 then
            stairsDown(length, width, depth, anchorSide, stairWidth, stairDepth, torchInterval)
        end
    end

    terpTarget.extend(self)
end
--endregion

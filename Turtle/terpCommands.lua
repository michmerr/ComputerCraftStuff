--region *.lua
--Date
require("terp")

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
        if lateral > 0 then
            if not terpTarget.stepLeft(lateral) then
                return false
            end
        elseif (lateral < 0) then
            if not terpTarget.stepRight(lateral * -1) then
                return false
            end
        end

        if forward > 0 then
            if not terpTarget.forward(forward) then
                return false
            end
        elseif (forward < 0) then
            if not terpTarget.reverse(forward * -1) then
                return false
            end
        end

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

    terpTarget.extend(self)
end
--endregion

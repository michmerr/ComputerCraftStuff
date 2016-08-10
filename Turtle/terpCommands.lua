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

    function self.digLayer(width, length)
        local turn = turnRight
        for j = 1, width - 1 do
            if not terpTarget.forward(length) then
                return false
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
        turn()
    end

    function self.tunnel(terpTarget, height, width, length)
        local offset = width / 2
        if not terpTarget.stepLeft(offset) then
            return false
        end
        for i = 1, height do
            if not self.digLayer(width, length) then
                return false
            end
            if i < height then
                if not terpTarget.up() then
                    return false
                end
            end
        end
        return true
    end

    function self.hole(terpTarget, length, width, depth, lateral_offset, offset)
        if lateral_offset > 0 then
            if not terpTarget.stepRight(lateral_offset) then
                return false
            end
        elseif (lateral_offset < 0) then
            if not terpTarget.stepLeft(lateral_offset * -1) then
                return false
            end
        end

        if offset > 0 then
            if not terpTarget.forward(offset) then
                return false
            end
        elseif (offset < 0) then
            if not terpTarget.back(offset * -1) then
                return false
            end
        end

        for d = 1, depth do
            if not terpTarget.down() then
                return false
            end
            if not self.digLayer(width, length) then
                return false
            end
        end
    end

    terpTarget.extend(self)
end
--endregion

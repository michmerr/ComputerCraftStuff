--region *.lua
--Date
--Mock terp

terp = {}

function terp.create()
    local self = {}

    function self.extend(table)
        return self.expected.extend
    end

    function self.turnRight()
        return self.expected.turnRight
    end

    function self.turnLeft()
        return self.expected.turnLeft
    end

    function self.dig()
        return self.expected.dig
    end

    function self.digUp()
        return self.expected.digUp
    end

    function self.digDown()
        return self.expected.digUp
    end

    function self.detect()
        return self.expected.detect
    end

    function self.detectUp()
        return self.expected.detectUp
    end

    function self.detectDown()
        return self.expected.detectDown
    end

    function self.detectRight()
        return self.expected.detectRight
    end

    function self.detectLeft()
        return self.expected.detectLeft
    end

    function self.detectBack()
        return self.expected.detectBack
    end

    function self.forward(distance)
        return self.expected.forward == distance
    end

    function self.back(distance)
        return self.expected.back == distance
    end

    function self.reverse(distance)
        return self.expected.reverse == distance
    end

    function self.up(distance)
        return self.expected.up == distance
    end

    function self.down(distance)
        return self.expected.down == distance
    end

    function self.right(distance)
        return self.expected.right == distance
    end

    function self.left(distance)
        return self.expected.left == distance
    end

    return self
end



--endregion

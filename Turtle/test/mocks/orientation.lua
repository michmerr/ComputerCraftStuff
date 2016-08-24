--region *.lua
--Date

function create(...)
    local self = {}
    local args = { ... }
    self.attitude = args[1]

    self.expected = { }

    function self.yawRight()
        return self.expected.yawRight
    end

    function self.yawLeft()
        return self.expected.yawLeft
    end

    function self.pitchUp()
        return self.expected.pitchDown
    end

    function self.pitchDown()
        return self.expected.pitchDown
    end

    function self.rollRight()
        return self.expected.rollRight
    end

    function self.rollLeft()
        return self.expected.rollLeft
    end

    local function translate(value)
        return value
    end

    function self.translateForward()
        return table.unpack(self.expected.translateForward)
    end

    function self.translateBackward()
        return table.unpack(self.expected.translateBackward)
    end

    function self.translateUp()
        return table.unpack(self.expected.translateUp)
    end

    function self.translateDown()
        return table.unpack(self.expected.translateDown)
    end

    function self.translateLeft()
        return table.unpack(self.expected.translateLeft)
    end

    function self.translateRight()
        return table.unpack(self.expected.translateRight)
    end

    self.expected.orientationCreateCalled = true

    return self;
end


--endregion

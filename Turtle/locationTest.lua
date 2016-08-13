--region *.lua

--Mock terp

require("mockTerp")

--Mock orientation base
orientation = {}

function orientation.create(...)
    local self = {}

    self.expected = { ... }

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

require("location")

function testCreate()
    local target = location.create()
    if not target then
        return false, "nil location returned from create()"
    end

    if not target.expected.orientationCreateCalled then
        return false, "orientation.create() not called"
    end
end

function testHelper(func, expected)
    local target = location.create()
    target.expected[expected] = { 0; 0; 0 }
    local x, y, z = target[func]()
    if not x == 0 then
        return false, "Did not see expected call to"..expected
    end
    return true
end

function testMoveForward()
    return testHelper("moveForward", "translateForward")
end

function testMoveBack()
    return testHelper("moveForward", "translateForward")
end

function testMoveUp()
    return testHelper("moveForward", "translateForward")
end

function testMoveDown()
    return testHelper("moveForward", "translateForward")
end

function testMoveLeft()
    return testHelper("moveForward", "translateForward")
end

function testMoveRight()
    return testHelper("moveForward", "translateForward")
end

function testLocationHelper(target, x, y, z)
    local actual = target.getLocation()
    if not (actual.x == x and actual.y == y and actual.z == z) then
        return false, string.format("Expected %d, %d, %d; Actual %d, %d, %d", x, y, z, actual.x, actual.y, actual.z)
    end
    return true
end

function testGetLocationInitial()
    local target = location.create()
    return testLocationHelper(target, 0, 0, 0)
end

function testGetLocationAfterSimpleMove()
    local target = location.create()
    target.expected.translateForward = { 0; 0; 1 }
    target.moveForward()
    return testLocationHelper(target, 0, 0, 1)
end

-- Distance to coords in right-angle moves
function testHowFar(x1, y1, z1)
    --TDOD
end

function test(func)
    local result, message = _G[func]()
    local resultString = "FAILED"
    if result then
        resultString = "PASSED"
    end
    if not message then
        message = ""
    end

    print(string.format("%s[%s] %s", func, resultString, message))
end

test("testCreate")
test("testMoveForward")
test("testMoveBack")
test("testMoveUp")
test("testMoveDown")
test("testMoveLeft")
test("testMoveRight")
test("testGetLocationInitial")
test("testGetLocationAfterSimpleMove")
test("testHowFar")

--endregion

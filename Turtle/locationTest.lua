--region *.lua
print("o = "..tostring(orientation))
--Mock terp

if require then
    require("mockTerp")
else
    os.loadAPI("test/terp")
end

--Mock orientation base
if orientation then
    if require then
        orientation = require("test/orientation")
    else
        os.unloadAPI("orientation")
        os.loadAPI("test/orientation")
    end
else
    if require then
        require("test/orientation")
    else
        os.loadAPI("test/orientation")
    end
end

if not location then
    if require then
        require("location")
    else
        os.loadAPI("location")
    end
end

if not matrix then
    if require then
        require("matrix")
    else
        os.loadAPI("matrix")
    end
end

function testCreateHelper(arg)
    print("ox = "..tostring(orientation))
    local target = location.create(arg)
    if not target then
        return false, "nil location returned from create()"
    end

    if not target.expected.orientationCreateCalled then
        return false, "orientation.create() not called"
    end

    if arg then
        if arg.attitude then
            local att = matrix.new(arg.attitude)
            if target.attitude ~= att then
                return false, string.format("expected specified initial orientation [ %s ], actual [ %s ]", att, target.attitude)
            end
        end
        if arg.x or arg.y or arg.z then
            local actual = target.getLocation()

            if arg.x and arg.x ~= actual.x then
                return false, string.format("Expected initial x location %d, actual %d",arg.x, actual.x)
            end
            if arg.y and arg.y ~= actual.y then
                return false, string.format("Expected initial y location %d, actual %d",arg.y, actual.y)
            end
            if arg.z and arg.z ~= actual.z then
                return false, string.format("Expected initial z location %d, actual %d",arg.z, actual.z)
            end
        end
    end
    return true
end

function testCreate()
    return testCreateHelper()
end

function testCreateWithOrientation()
    return testCreateHelper({ attitude = { { 0; 0; 1 }; { -1, 0, 0 }; { 0; 1; 0 } } })
end

function testCreateWithLocation()
    return testCreateHelper({ x = 5; y = 12; z = 1 })
end

function testCreateBoth()
    return testCreateHelper({ x = 5; y = 12; z = 1 ; attitude = { { 0; 0; 1 }; { -1, 0, 0 }; { 0; 1; 0 } } })
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
function testHowFarHelper(x, y, z, x1, y1, z1)
    local target = location.create(x1 and { x = x1, y = y1, z = z1 })
    local actual = target.howFar(x, y, z)
    local expected = math.abs(x - (x1 or 0)) + math.abs(y - (y1 or 0)) + math.abs(z - (z1 or 0))

    if actual ~= expected then
        return false, string.format("Expected %d, actual %d", expected, actual)
    end
    return true
end

function testHowFar()
    return testHowFarHelper(0, 0, 0)
end

function testHowFarPos()
    return testHowFarHelper(10, 10, 10)
end

function testHowFarNeg()
    return testHowFarHelper(-10, -10, -10)
end

function testHowFarMixed()
    return testHowFarHelper(10, -10, 10)
end

function testHowFarRelative()
    return testHowFarHelper(0, 0, 0, 16, 4, 9)
end

function testHowFarRelative2()
    return testHowFarHelper(10, -9, 0, 16, 4, 9)
end

function test(id, func)
    local result, message = func()
    local resultString = "FAILED"
    if result then
        resultString = "PASSED"
    end
    if not message then
        message = ""
    end

    print(string.format("%s[%s] %s", id, resultString, message))
end

test("testCreate", testCreate)
test("testCreateWithOrientation", testCreateWithOrientation)
test("testCreateWithLocation", testCreateWithLocation)
test("testCreateBoth", testCreateBoth)
test("testMoveForward", testMoveForward)
test("testMoveBack", testMoveBack)
test("testMoveUp", testMoveUp)
test("testMoveDown", testMoveDown)
test("testMoveLeft", testMoveLeft)
test("testMoveRight", testMoveRight)
test("testGetLocationInitial", testGetLocationInitial)
test("testGetLocationAfterSimpleMove", testGetLocationAfterSimpleMove)
test("testHowFar", testHowFar)
test("testHowFarPos", testHowFarPos)
test("testHowFarNeg", testHowFarNeg)
test("testHowFarMixed", testHowFarMixed)
test("testHowFarRelative", testHowFarRelative)
test("testHowFarRelative2", testHowFarRelative2)

--endregion

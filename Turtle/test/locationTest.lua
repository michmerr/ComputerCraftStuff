--region *.lua

--Mock terp

if not testCommon then
    os.loadAPI("./testCommon")
end

testCommon.reloadAPI("terp", "test/mocks/terp")
testCommon.reloadAPI("orientation", "test/mocks/orientation")
testCommon.reloadAPI("location", "location")
testCommon.reloadAPI("matrix", "matrix")

function _testCreateHelper(arg)
    local target = location.create(arg)
    assert(target, "nil location returned from create()")

    assert(orientation.getMockData and orientation.getMockData().calls[1] and orientation.getMockData().calls[1] == "create", "orientation.create() not called")

    if arg then
        if arg.attitude then
            local att = matrix.new(arg.attitude)
            assert(target.attitude == att, string.format("expected specified initial orientation [ %s ], actual [ %s ]", tostring(att), tostring(target.attitude)))
        end
        if arg.x or arg.y or arg.z then
            local actual = target.getLocation()

            assert(arg.x and arg.x == actual.x, string.format("Expected initial x location %d, actual %d",arg.x, actual.x))
            assert(arg.y and arg.y == actual.y, string.format("Expected initial y location %d, actual %d",arg.y, actual.y))
            assert(arg.z and arg.z == actual.z, string.format("Expected initial z location %d, actual %d",arg.z, actual.z))
        end
    end
    return true
end

function testCreate()
    _testCreateHelper()
end

function testCreateWithOrientation()
    _testCreateHelper({ attitude = { { 0; 0; 1 }; { -1, 0, 0 }; { 0; 1; 0 } } })
end

function testCreateWithLocation()
    _testCreateHelper({ x = 5; y = 12; z = 1 })
end

function testCreateBoth()
    _testCreateHelper({ x = 5; y = 12; z = 1 ; attitude = { { 0; 0; 1 }; { -1, 0, 0 }; { 0; 1; 0 } } })
end

function _testHelper(func, expected)
    local target = location.create()
    local globalMockOrientationData = orientation.getMockData()
    local instanceMockData = globalMockOrientationData.instances[#globalMockOrientationData.instances]
    instanceMockData.expected[expected] = { { 2, 0, 0 } }
    local loc = target[func]()
    assert(loc and loc.x == 2, "Did not see expected call to"..expected)
    return true
end

function testMoveForward()
    _testHelper("moveForward", "translateForward")
end

function testMoveBack()
    _testHelper("moveBack", "translateBackward")
end

function testMoveUp()
    _testHelper("moveUp", "translateUp")
end

function testMoveDown()
    _testHelper("moveDown", "translateDown")
end

function testMoveLeft()
    _testHelper("moveLeft", "translateLeft")
end

function testMoveRight()
    _testHelper("moveRight", "translateRight")
end

function _testLocationHelper(target, x, y, z)
    local actual = target.getLocation()
    assert((actual.x == x and actual.y == y and actual.z == z), string.format("Expected %d, %d, %d; Actual %d, %d, %d", x, y, z, actual.x, actual.y, actual.z))
    return true
end

function testGetLocationInitial()
    local target = location.create()
    _testLocationHelper(target, 0, 0, 0)
end

function testGetLocationAfterSimpleMove()
    local target = location.create()
    local globalMockOrientationData = orientation.getMockData()
    local instanceMockData = globalMockOrientationData.instances[#globalMockOrientationData.instances]
    instanceMockData.expected.translateForward = { { 0; 0; 1 } }
    target.moveForward()
    _testLocationHelper(target, 0, 0, 1)
end

-- Distance to coords in right-angle moves
function _testHowFarHelper(x, y, z, x1, y1, z1)
    local target = location.create(x1 and { x = x1, y = y1, z = z1 })
    local actual = target.howFar(x, y, z)
    local expected = math.abs(x - (x1 or 0)) + math.abs(y - (y1 or 0)) + math.abs(z - (z1 or 0))

    assert(actual == expected, string.format("Expected %d, actual %d", expected, actual))
    return true
end

function testHowFar()
    _testHowFarHelper(0, 0, 0)
end

function testHowFarPos()
    _testHowFarHelper(10, 10, 10)
end

function testHowFarNeg()
    _testHowFarHelper(-10, -10, -10)
end

function testHowFarMixed()
    _testHowFarHelper(10, -10, 10)
end

function testHowFarRelative()
    _testHowFarHelper(0, 0, 0, 16, 4, 9)
end

function testHowFarRelative2()
    _testHowFarHelper(10, -9, 0, 16, 4, 9)
end

function testDecorate()
    assert(false, "TODO")
end

--endregion

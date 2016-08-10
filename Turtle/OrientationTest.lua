--region *.lua
--Date

require("orientation")

local function testCreate()
    local target = orientation.create()

    assert(target, "Should not be null")
end

local function compare(matrixA, matrixB)
    if not matrixA and not matrixB then
        return true
    end

    if not matrixA or not matrixB then
        return false
    end

    if type(matrixA) ~= type(matrixB) then
        return false
    end

    if type(matrixA) ~= "table" then
        return matrixA == matrixB
    end

    if #matrixA ~= #matrixB then
        return false
    end

    for i = 1, #matrixA do
        if not compare(matrixA[i], matrixB[i]) then
            return false
        end
    end

    return true
end

local function testHelper(func, expected)
    local actual = func()
    if not compare(expected, actual) then
        print("Results do not match.")
        print("Expected: ")
        print(Orientation.printMatrix(expected))
        print("Actual: ")
        print(Orientation.printMatrix(actual))
        return false;
    end
    return true;
end

local function testForward(target, expected)
    return testHelper(target.translateForward, expected)
end

local function testBackwards(target, expected)
    return testHelper(target.translateBackward, expected)
end

local function testLeft(target, expected)
    return testHelper(target.translateLeft, expected)
end

local function testRight(target, expected)
    return testHelper(target.translateRight, expected)
end

local function testUp(target, expected)
    return testHelper(target.translateUp, expected)
end

local function testDown(target, expected)
    return testHelper(target.translateDown, expected)
end

local function testNeutral()
    local target = Orientation.create()
    print("testForward ["..((testForward(target, { 0, 0, 1 } ) and "passed]") or "FAILED]"))
    print("testBackwards ["..((testBackwards(target, { 0, 0, -1 } ) and "passed]") or "FAILED]"))
    print("testLeft ["..((testLeft(target, { -1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testRight ["..((testRight(target, { 1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testUp ["..((testUp(target, { 0, 1, 0 } ) and "passed]") or "FAILED]"))
    print("testDown ["..((testDown(target, { 0, -1, 0 }) and "passed]") or "FAILED]"))
end

local function testFacingRight()
    local target = Orientation.create()
    target.yawRight()
    print("testForwardFacingRight ["..((testForward(target, { 1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testBackwardsFacingRight ["..((testBackwards(target, { -1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testLeftFacingRight ["..((testLeft(target, { 0, 0, 1 } ) and "passed]") or "FAILED]"))
    print("testRightFacingRight ["..((testRight(target, { 0, 0, -1 } ) and "passed]") or "FAILED]"))
    print("testUpFacingRight ["..((testUp(target, { 0, 1, 0 } ) and "passed]") or "FAILED]"))
    print("testDownFacingRight ["..((testDown(target, { 0, -1, 0 }) and "passed]") or "FAILED]"))
end

local function testFacingLeft()
    local target = Orientation.create()
    target.yawLeft()
    print("testForwardFacingLeft ["..((testForward(target, { -1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testBackwardsFacingLeft ["..((testBackwards(target, { 1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testLeftFacingLeft ["..((testLeft(target, { 0, 0, -1 } ) and "passed]") or "FAILED]"))
    print("testRightFacingLeft ["..((testRight(target, { 0, 0, 1 } ) and "passed]") or "FAILED]"))
    print("testUpFacingLeft ["..((testUp(target, { 0, 1, 0 } ) and "passed]") or "FAILED]"))
    print("testDownFacingLeft ["..((testDown(target, { 0, -1, 0 }) and "passed]") or "FAILED]"))
end

local function testFacingBack()
    local target = Orientation.create()
    target.yawLeft()
    target.yawLeft()
    print("testForwardFacingBack ["..((testForward(target, { 0, 0, -1 } ) and "passed]") or "FAILED]"))
    print("testBackwardsFacingBack ["..((testBackwards(target, { 0, 0, 1 } ) and "passed]") or "FAILED]"))
    print("testLeftFacingBack ["..((testLeft(target, { 1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testRightFacingBack ["..((testRight(target, { -1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testUpFacingBack ["..((testUp(target, { 0, 1, 0 } ) and "passed]") or "FAILED]"))
    print("testDownFacingBack ["..((testDown(target, { 0, -1, 0 }) and "passed]") or "FAILED]"))
end

local function testFacingUp()
    local target = Orientation.create()
    target.pitchUp()
    print("testForwardFacingUp ["..((testForward(target, { 0, 1, 0 } ) and "passed]") or "FAILED]"))
    print("testBackwardsFacingUp ["..((testBackwards(target, { 0, -1, 0 } ) and "passed]") or "FAILED]"))
    print("testLeftFacingUp ["..((testLeft(target, { -1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testRightFacingUp ["..((testRight(target, { 1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testUpFacingUp ["..((testUp(target, { 0, 0, -1 } ) and "passed]") or "FAILED]"))
    print("testDownFacingUp ["..((testDown(target, { 0, 0, 1 }) and "passed]") or "FAILED]"))
end

local function testFacingDown()
    local target = Orientation.create()
    target.pitchDown()
    print("testForwardFacingDown ["..((testForward(target, { 0, -1, 0 } ) and "passed]") or "FAILED]"))
    print("testBackwardsFacingDown ["..((testBackwards(target, { 0, 1, 0 } ) and "passed]") or "FAILED]"))
    print("testLeftFacingDown ["..((testLeft(target, { -1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testRightFacingDown ["..((testRight(target, { 1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testUpFacingDown ["..((testUp(target, { 0, 0, 1 } ) and "passed]") or "FAILED]"))
    print("testDownFacingDown ["..((testDown(target, { 0, 0, -1 }) and "passed]") or "FAILED]"))
end


local function testRolledRight()
    local target = Orientation.create()
    target.rollRight()
    print("testForwardRolledRight ["..((testForward(target, { 0, 0, 1 } ) and "passed]") or "FAILED]"))
    print("testBackwardsRolledRight ["..((testBackwards(target, { 0, 0, -1 } ) and "passed]") or "FAILED]"))
    print("testLeftRolledRight ["..((testLeft(target, { 0, 1, 0 } ) and "passed]") or "FAILED]"))
    print("testRightRolledRight ["..((testRight(target, { 0, -1, 0 } ) and "passed]") or "FAILED]"))
    print("testUpRolledRight ["..((testUp(target, { 1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testDownRolledRight ["..((testDown(target, { -1, 0, 0 }) and "passed]") or "FAILED]"))
end


local function testRolledLeft()
    local target = Orientation.create()
    target.rollLeft()
    print("testForwardRolledLeft ["..((testForward(target, { 0, 0, 1 } ) and "passed]") or "FAILED]"))
    print("testBackwardsRolledLeft ["..((testBackwards(target, { 0, 0, -1 } ) and "passed]") or "FAILED]"))
    print("testLeftRolledLeft ["..((testLeft(target, { 0, -1, 0 } ) and "passed]") or "FAILED]"))
    print("testRightRolledLeft ["..((testRight(target, { 0, 1, 0 } ) and "passed]") or "FAILED]"))
    print("testUpRolledLeft ["..((testUp(target, { -1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testDownRolledLeft ["..((testDown(target, { 1, 0, 0 }) and "passed]") or "FAILED]"))
end


local function testFacingUpThenRight()
    local target = Orientation.create()
    target.pitchUp()
    target.yawRight()
    print("testForwardFacingUpThenRight ["..((testForward(target, { 1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testBackwardsFacingUpThenRight ["..((testBackwards(target, { -1, 0, 0 } ) and "passed]") or "FAILED]"))
    print("testLeftFacingUpThenRight ["..((testLeft(target, { 0, 1, 0 } ) and "passed]") or "FAILED]"))
    print("testRighFacingUpThenRight ["..((testRight(target, { 0, -1, 0 } ) and "passed]") or "FAILED]"))
    print("testUpFacingUpThenRight ["..((testUp(target, { 0, 0, -1 } ) and "passed]") or "FAILED]"))
    print("testDownFacingUpThenRight ["..((testDown(target, { 0, 0, 1 }) and "passed]") or "FAILED]"))
end

testNeutral()
testFacingRight()
testFacingLeft()
testFacingBack()
testFacingUp()
testFacingDown()
testRolledLeft()
testRolledRight()
testFacingUpThenRight()

--endregion

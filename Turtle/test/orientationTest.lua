-- region *.lua
-- Date

if not testCommon then
  os.loadAPI("testCommon")
end

testCommon.reloadAPI("orientation", "orientation")

function testCreate()
  local target = orientation.create()

  assert(target, "Should not be null")
end

-- testing the returned format. the other facing tests address changes in facing and their effect on translations.
function testGetFacing()
  local target = orientation.create()
  local facing = target.getFacing()
  assert(facing.x == 0 and facing.y == 0 and facing.z == 1, string.format("Expected 0, 0, 1; Actual %d, %d, %d", facing.x, facing.y, facing.z))
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
  local actual = { func() }
  if not compare(expected, actual) then
    local err = err .. "Results do not match.\nExpected:\n"
    local line = ""
    for i = 1, #expected do
      line = line .. "  " .. expected[i]
    end
    err = err .. line .. "\n"
    err = err .. "Actual:\n"
    line = ""
    for i = 1, #actual do
      line = line .. "  " .. actual[i]
    end
    err = err .. line .. "\n"
    return false, err;
  end
  return true;
end

local function testForward(target, expected)
  assert(testHelper(target.translateForward, expected))
end

local function testBackwards(target, expected)
  assert(testHelper(target.translateBackward, expected))
end

local function testLeft(target, expected)
  assert(testHelper(target.translateLeft, expected))
end

local function testRight(target, expected)
  assert(testHelper(target.translateRight, expected))
end

local function testUp(target, expected)
  assert(testHelper(target.translateUp, expected))
end

local function testDown(target, expected)
  assert(testHelper(target.translateDown, expected))
end

local function testNeutral(func, expected)
  local target = orientation.create()
  func(target, expected)
end

function testForwardNeutral()
  testNeutral(testForward, { 0, 0, 1 })
end

function testBackwardsNeutral()
  testNeutral(testBackwards, { 0, 0, - 1 })
end

function testLeftNeutral()
  testNeutral(testLeft, { - 1, 0, 0 })
end

function testRightNeutral()
  testNeutral(testRight, { 1, 0, 0 })
end

function testUpNeutral()
  testNeutral(testUp, { 0, 1, 0 })
end

function testDownNeutral()
  testNeutral(testDown, { 0, - 1, 0 })
end


local function testFacingRight(func, expected)
  local target = orientation.create()
  target.yawRight()
  func(target, expected)
end

function testForwardFacingRight()
  testFacingRight(testForward, { 1, 0, 0 })
end


function testBackwardsFacingRight()
  testFacingRight(testBackwards, { - 1, 0, 0 })
end


function testLeftFacingRight()
  testFacingRight(testLeft, { 0, 0, 1 })
end


function testRightFacingRight()
  testFacingRight(testRight, { 0, 0, - 1 })
end


function testUpFacingRight()
  testFacingRight(testUp, { 0, 1, 0 })
end


function testDownFacingRight()
  testFacingRight(testDown, { 0, - 1, 0 })
end



local function testFacingLeft(func, expected)
  local target = orientation.create()
  target.yawLeft()
  func(target, expected)
end


function testForwardFacingLeft()
  testFacingLeft(testForward, { - 1, 0, 0 })
end


function testBackwardsFacingLeft()
  testFacingLeft(testBackwards, { 1, 0, 0 })
end


function testLeftFacingLeft()
  testFacingLeft(testLeft, { 0, 0, - 1 })
end


function testRightFacingLeft()
  testFacingLeft(testRight, { 0, 0, 1 })
end


function testUpFacingLeft()
  testFacingLeft(testUp, { 0, 1, 0 })
end


function testDownFacingLeft()
  testFacingLeft(testDown, { 0, - 1, 0 })
end



local function testFacingBack(func, expected)
  local target = orientation.create()
  target.yawLeft()
  target.yawLeft()
  func(target, expected)
end


function testForwardFacingBack()
  testFacingBack(testForward, { 0, 0, - 1 })
end


function testBackwardsFacingBack()
  testFacingBack(testBackwards, { 0, 0, 1 })
end


function testLeftFacingBack()
  testFacingBack(testLeft, { 1, 0, 0 })
end


function testRightFacingBack()
  testFacingBack(testRight, { - 1, 0, 0 })
end


function testUpFacingBack()
  testFacingBack(testUp, { 0, 1, 0 })
end


function testDownFacingBack()
  testFacingBack(testDown, { 0, - 1, 0 })
end



local function testFacingUp(func, expected)
  local target = orientation.create()
  target.pitchUp()
  func(target, expected)
end

function testForwardFacingUp()
  testFacingUp(testForward, { 0, 1, 0 })
end


function testBackwardsFacingUp()
  testFacingUp(testBackwards, { 0, - 1, 0 })
end


function testLeftFacingUp()
  testFacingUp(testLeft, { - 1, 0, 0 })
end


function testRightFacingUp()
  testFacingUp(testRight, { 1, 0, 0 })
end


function testUpFacingUp()
  testFacingUp(testUp, { 0, 0, - 1 })
end


function testDownFacingUp()
  testFacingUp(testDown, { 0, 0, 1 })
end


local function testFacingDown(func, expected)
  local target = orientation.create()
  target.pitchDown()
  func(target, expected)
end

function testForwardFacingDown()
  testFacingDown(testForward, { 0, - 1, 0 })
end


function testBackwardsFacingDown()
  testFacingDown(testBackwards, { 0, 1, 0 })
end


function testLeftFacingDown()
  testFacingDown(testLeft, { - 1, 0, 0 })
end


function testRightFacingDown()
  testFacingDown(testRight, { 1, 0, 0 })
end


function testUpFacingDown()
  testFacingDown(testUp, { 0, 0, 1 })
end


function testDownFacingDown()
  testFacingDown(testDown, { 0, 0, - 1 })
end



local function testRolledRight(func, expected)
  local target = orientation.create()
  target.rollRight()
  func(target, expected)
end

function testForwardRolledRight()
  testRolledRight(testForward, { 0, 0, 1 })
end


function testBackwardsRolledRight()
  testRolledRight(testBackwards, { 0, 0, - 1 })
end


function testLeftRolledRight()
  testRolledRight(testLeft, { 0, 1, 0 })
end


function testRightRolledRight()
  testRolledRight(testRight, { 0, - 1, 0 })
end


function testUpRolledRight()
  testRolledRight(testUp, { 1, 0, 0 })
end


function testDownRolledRight()
  testRolledRight(testDown, { - 1, 0, 0 })
end



local function testRolledLeft(func, expected)
  local target = orientation.create()
  target.rollLeft()
  func(target, expected)
end


function testForwardRolledLeft()
  testRolledLeft(testForward, { 0, 0, 1 })
end


function testBackwardsRolledLeft()
  testRolledLeft(testBackwards, { 0, 0, - 1 })
end


function testLeftRolledLeft()
  testRolledLeft(testLeft, { 0, - 1, 0 })
end


function testRightRolledLeft()
  testRolledLeft(testRight, { 0, 1, 0 })
end


function testUpRolledLeft()
  testRolledLeft(testUp, { - 1, 0, 0 })
end


function testDownRolledLeft()
  testRolledLeft(testDown, { 1, 0, 0 })
end


local function testFacingUpThenRight(func, expected)
  local target = orientation.create()
  target.pitchUp()
  target.yawRight()
  func(target, expected)
end

function testForwardFacingUpThenRight()
  testFacingUpThenRight(testForward, { 1, 0, 0 })
end


function testBackwardsFacingUpThenRight()
  testFacingUpThenRight(testBackwards, { - 1, 0, 0 })
end


function testLeftFacingUpThenRight()
  testFacingUpThenRight(testLeft, { 0, 1, 0 })
end

function testRighFacingUpThenRight()
  testFacingUpThenRight(testRight, { 0, - 1, 0 })
end

function testUpFacingUpThenRight()
  testFacingUpThenRight(testUp, { 0, 0, - 1 })
end


function testDownFacingUpThenRight()
  testFacingUpThenRight(testDown, { 0, 0, 1 })
end

-- endregion

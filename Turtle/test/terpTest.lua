-- region *.lua
-- Date

local directions = {
  forward = { name = "forward"; detect = "detect"; attack = "attack"; dig = "dig"; place = "place"; inspect = "inspect" };
  up = { name = "up"; detect = "detectUp"; attack = "attackUp"; dig = "digUp"; place = "placeUp"; inspect = "inspectUp" };
  down = { name = "down"; detect = "detectDown"; attack = "attackDown"; dig = "digDown"; place = "placeDown"; inspect = "inspectDown" };
}

if not testCommon then
  os.loadAPI("test/testCommon")
end

function init()
  testCommon.reloadAPI("turtle", "test/mocks/turtle")
  testCommon.reloadAPI("terp", "terp")
end

function stackToString(list)
  local result

  for i = 1, #list do
    result = result and result .. ", " .. list[i] or list[i]
  end

  return result
end

function evaluateMockData(expected)
  local actual = turtle.getMockData()
  assert(#actual.calls, #expected, "Call counts did not match: Expected: " .. stackToString(expected) .. "  Actual: " .. stackToString(actual.calls))
  for i = 1, #expected do
    assert(expected[i] == actual.calls[i], "Value mismatch at index " .. tostring(i) .. ".  Expected: " .. stackToString(expected) .. "  Actual: " .. stackToString(actual.calls))
  end
  return true
end

function testTurnAround()
  init()
  local mockData = turtle.getMockData()
  mockData.expected.turnRight = { true; true }
  local actual = terp.turnAround()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " ,  turtle calls: " .. stackToString(mockData.calls))
  local expected = { "turnRight", "turnRight" }
  evaluateMockData(expected)
  return true
end

function testDetectRight()
  init()
  local mockData = turtle.getMockData()
  mockData.expected.turnRight = { true }
  mockData.expected.turnLeft = { true }
  mockData.expected.detect = { true }
  local actual = terp.detectRight()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { "turnRight", "detect", "turnLeft" }
  evaluateMockData(expected)
  return true
end

function testDetectLeft()
  init()
  local mockData = turtle.getMockData()
  mockData.expected.turnLeft = { true }
  mockData.expected.turnRight = { true }
  mockData.expected.detect = { true }
  local actual = terp.detectLeft()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { "turnLeft", "detect", "turnRight" }
  evaluateMockData(expected)
  return true
end

function testDetectBack()
  init()
  local mockData = turtle.getMockData()
  mockData.expected.turnRight = { true; true; true; true }
  mockData.expected.detect = { true }
  local actual = terp.detectBack()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { "turnRight", "turnRight", "detect", "turnRight", "turnRight" }
  evaluateMockData(expected)
  return true
end

function testBack()
  init()
  local mockData = turtle.getMockData()
  mockData.expected.back = { true }
  local actual = terp.back()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle.expected.back: " .. tostring(#mockData.expected.back) .. " turtle calls: " .. stackToString(mockData.calls))
  local expected = { "back" }
  evaluateMockData(expected)
  return true
end

function testBackWithObstruction()
  init()
  local mockData = turtle.getMockData()
  mockData.expected.back = { false }
  mockData.expected.forward = { false, true }
  mockData.expected.detect = { true }
  mockData.expected.dig = { true }
  mockData.expected.turnRight = { true; true; true; true }
  local actual = terp.back()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { "back", "turnRight", "turnRight", "forward", "detect", "dig", "forward", "turnRight", "turnRight" }
  evaluateMockData(expected)
  return true
end

function _testMove(direction)
  init()
  local mockData = turtle.getMockData()
  mockData.expected[direction.name] = { true }
  local actual = terp[direction.name]()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { direction.name }
  evaluateMockData(expected)
  return true
end

function testForward()
  return _testMove(directions.forward)
end

function testUp()
  return _testMove(directions.up)
end

function testDown()
  return _testMove(directions.down)
end

function _testMoveWithBlock(direction)
  init()
  local mockData = turtle.getMockData()
  mockData.expected[direction.name] = { false, true }
  mockData.expected[direction.detect] = { true, false }
  mockData.expected[direction.dig] = { true }
  local actual = terp[direction.name]()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { direction.name, direction.detect, direction.dig, direction.name }
  evaluateMockData(expected)
  return true
end

function testForwardWithBlock()
  return _testMoveWithBlock(directions.forward)
end

function testUpWithBlock()
  return _testMoveWithBlock(directions.up)
end

function testDownWithBlock()
  return _testMoveWithBlock(directions.down)
end

function _testMoveWithFallingBlock(direction)
  init()
  local mockData = turtle.getMockData()
  mockData.expected[direction.name] = { false, false, true }
  mockData.expected[direction.detect] = { true, true }
  mockData.expected[direction.dig] = { true, true }
  local actual = terp[direction.name]()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { direction.name, direction.detect, direction.dig, direction.name, direction.detect, direction.dig, direction.name }
  evaluateMockData(expected)
  return true
end

function testForwardWithFallingBlock()
  return _testMoveWithFallingBlock(directions.forward)
end

function testUpWithFallingBlock()
  return _testMoveWithFallingBlock(directions.up)
end

function testDownWithFallingBlock()
  return _testMoveWithFallingBlock(directions.down)
end

function _testMoveWithMob(direction)
  init()
  local mockData = turtle.getMockData()
  mockData.expected[direction.name] = { false, true }
  mockData.expected[direction.detect] = { false, false }
  mockData.expected[direction.attack] = { true, false }
  mockData.expected["getFuelLevel"] = { 100 }
  local actual = terp[direction.name]()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { direction.name, direction.detect, "getFuelLevel", direction.attack, direction.name }
  evaluateMockData(expected)
  return true
end

function testForwardWithMob()
  return _testMoveWithMob(directions.forward)
end

function testUpWithMob()
  return _testMoveWithMob(directions.up)
end

function testDownWithMob()
  return _testMoveWithMob(directions.down)
end

function _testMoveWithNoFuel(direction)
  init()
  local mockData = turtle.getMockData()
  mockData.expected[direction.name] = { false }
  mockData.expected[direction.detect] = { false }
  mockData.expected.getFuelLevel = { 0 }
  local actual, err = terp[direction.name]()
  assert(not actual and err == terp.OUT_OF_FUEL, "Expected false result with error message, actual: " .. tostring(actual) .. ":" .. tostring(err) .. ", turtle calls: " .. stackToString(mockData.calls))
  local expected = { direction.name, direction.detect, "getFuelLevel" }
  evaluateMockData(expected)
  return true
end

function testForwardWithNoFuel()
  return _testMoveWithNoFuel(directions.forward)
end

function testUpWithNoFuel()
  return _testMoveWithNoFuel(directions.up)
end

function testDownWithNoFuel()
  return _testMoveWithNoFuel(directions.down)
end

function testRight()
  init()
  local mockData = turtle.getMockData()
  mockData.expected.turnRight = { true }
  mockData.expected.turnLeft = { true }
  mockData.expected.forward = { true }
  local actual = terp.right()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { "turnRight", "forward", "turnLeft" }
  evaluateMockData(expected)
  return true
end

function testRightMulti()
  init()
  local mockData = turtle.getMockData()
  mockData.expected.turnRight = { true }
  mockData.expected.turnLeft = { true }
  mockData.expected.forward = { true, true, true }
  local actual = terp.right(3)
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { "turnRight", "forward", "forward", "forward", "turnLeft" }
  evaluateMockData(expected)
  return true
end

function testLeft()
  init()
  local mockData = turtle.getMockData()
  mockData.expected.turnLeft = { true }
  mockData.expected.turnRight = { true }
  mockData.expected.forward = { true }
  local actual = terp.left()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { "turnLeft", "forward", "turnRight" }
  evaluateMockData(expected)
  return true
end

function testLeftMulti()
  init()
  local mockData = turtle.getMockData()
  mockData.expected.turnLeft = { true }
  mockData.expected.turnRight = { true }
  mockData.expected.forward = { true, true, true }
  local actual = terp.left(3)
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { "turnLeft", "forward", "forward", "forward", "turnRight" }
  evaluateMockData(expected)
  return true
end

function _testPlace(direction)
  init()
  local mockData = turtle.getMockData()
  mockData.expected[direction.place] = { true }
  local actual = terp[direction.place]()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { direction.place }
  evaluateMockData(expected)
  return true
end

function _testPlaceBlocked(direction)
  init()
  local mockData = turtle.getMockData()
  mockData.expected[direction.place] = { false }
  mockData.expected[direction.detect] = { true }
  local actual = terp[direction.place]()
  assert(not actual, "Expected false result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { direction.place, direction.detect }
  evaluateMockData(expected)
  return true
end

function _testPlaceMob(direction)
  init()
  local mockData = turtle.getMockData()
  mockData.expected[direction.place] = { false, true }
  mockData.expected[direction.detect] = { false }
  mockData.expected[direction.attack] = { true, false }
  local actual = terp[direction.place]()
  assert(actual, "Expected true result, actual: " .. tostring(actual) .. " , turtle calls: " .. stackToString(mockData.calls))
  local expected = { direction.place, direction.detect, direction.attack, direction.attack, direction.place }
  evaluateMockData(expected)
  return true
end

function testPlace()
  return _testPlace(directions.forward)
end

function testPlaceBlocked()
  return _testPlaceBlocked(directions.forward)
end

function testPlaceMob()
  return _testPlaceMob(directions.forward)
end

function testPlaceUp()
  return _testPlace(directions.up)
end

function testPlaceUpBlocked()
  return _testPlaceBlocked(directions.up)
end

function testPlaceUpMob()
  return _testPlaceMob(directions.up)
end

function testPlaceDown()
  return _testPlace(directions.down)
end

function testPlaceDownBlocked()
  return _testPlaceBlocked(directions.down)
end

function testPlaceDownMob()
  return _testPlaceMob(directions.down)
end

-- endregion

--region *.lua
--Date
--region *.lua
--Date

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
    result = result and result..", "..list[i] or list[i]
  end

  return result
end

function evaluateMockData(expected)
  local actual = turtle.getMockData()
  assert(#actual.calls, #expected, "Call counts did not match: Expected: "..stackToString(expected).."  Actual: "..stackToString(actual.calls))
  for i = 1, #expected do
    assert(expected[i] == actual.calls[i], "Value mismatch at index "..tostring(i)..".  Expected: "..stackToString(expected).."  Actual: "..stackToString(actual.calls))
  end
  return true
end

function testTurnAround()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.turnRight = { true; true }
    local actual = turtle.turnAround()
    assert(actual, "Expected true result, actual: "..tostring(actual).." ,  turtle calls: "..stackToString(mockData.calls))
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
    local actual = turtle.detectRight()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
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
    local actual = turtle.detectLeft()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "turnLeft", "detect", "turnRight" }
    evaluateMockData(expected)
    return true
end

function testDetectBack()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.turnRight = { true; true; true; true }
    mockData.expected.detect = { true }
    local actual = turtle.detectBack()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "turnRight",  "turnRight", "detect", "turnRight", "turnRight" }
    evaluateMockData(expected)
    return true
end

function testBack()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.back = { true }
    local actual = turtle.back()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle.expected.back: "..tostring(#mockData.expected.back).." turtle calls: "..stackToString(mockData.calls))
    local expected = { "back" }
    evaluateMockData(expected)
    return true
end

function testBackWithObstruction()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.back = { false }
    mockData.expected.forward = { true }
    mockData.expected.detect = { true }
    mockData.expected.dig = { true }
    mockData.expected.turnRight = { true; true; true; true }
    local actual = turtle.back()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "back", "turnRight", "turnRight", "detect", "dig", "forward", "turnRight", "turnRight" }
    evaluateMockData(expected)
    return true
end

function testForward()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.forward = { true }
    mockData.expected.detect = { false }
    local actual = turtle.forward()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detect", "forward" }
    evaluateMockData(expected)
    return true
end

function testForwardWithBlock()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.forward = { true }
    mockData.expected.detect = { true, false }
    mockData.expected.dig = { true }
    local actual = turtle.forward()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detect", "dig", "forward" }
    evaluateMockData(expected)
    return true
end

function testForwardWithFallingBlock()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.forward = { false, true }
    mockData.expected.detect = { true, true }
    mockData.expected.dig = { true, true }
    local actual = turtle.forward()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detect", "dig", "forward", "detect", "dig", "forward" }
    evaluateMockData(expected)
    return true
end

function testForwardWithMob()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.forward = { false, true }
    mockData.expected.detect = { false, false }
    mockData.expected.attack = { true, false }
    local actual = turtle.forward()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detect", "forward", "detect", "attack", "forward" }
    evaluateMockData(expected)
    return true
end

function testUp()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.up = { true }
    mockData.expected.detectUp = { false }
    local actual = turtle.up()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detectUp", "up" }
    evaluateMockData(expected)
    return true
end

function testDown()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.down = { true }
    mockData.expected.detectDown = { false }
    local actual = turtle.down()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detectDown", "down" }
    evaluateMockData(expected)
    return true
end

function testRight()
   init()
    local mockData = turtle.getMockData()
    mockData.expected.turnRight = { true }
    mockData.expected.turnLeft = { true }
    mockData.expected.detect = { false }
    mockData.expected.forward = { true }
    local actual = turtle.right()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "turnRight", "detect", "forward", "turnLeft" }
    evaluateMockData(expected)
    return true
end

function testRightMulti()
   init()
    local mockData = turtle.getMockData()
    mockData.expected.turnRight = { true }
    mockData.expected.turnLeft = { true }
    mockData.expected.detect = { false, false, false }
    mockData.expected.forward = { true, true, true }
    local actual = turtle.right(3)
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "turnRight", "detect", "forward", "detect", "forward", "detect", "forward", "turnLeft" }
    evaluateMockData(expected)
    return true
end

function testLeft()
   init()
    local mockData = turtle.getMockData()
    mockData.expected.turnLeft = { true }
    mockData.expected.turnRight = { true }
    mockData.expected.detect = { false }
    mockData.expected.forward = { true }
    local actual = turtle.left()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "turnLeft", "detect", "forward", "turnRight" }
    evaluateMockData(expected)
    return true
end

function testLeftMulti()
   init()
    local mockData = turtle.getMockData()
    mockData.expected.turnLeft = { true }
    mockData.expected.turnRight = { true }
    mockData.expected.detect = { false, false, false }
    mockData.expected.forward = { true, true, true }
    local actual = turtle.left(3)
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "turnLeft", "detect", "forward", "detect", "forward", "detect", "forward", "turnRight" }
    evaluateMockData(expected)
    return true
end

function testPlace()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.place = { true }
    mockData.expected.detect = { false }
    local actual = turtle.place()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detect", "place" }
    evaluateMockData(expected)
    return true
end

function testPlaceBlocked()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.detect = { true }
    local actual = turtle.place()
    assert(not actual, "Expected false result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detect" }
    evaluateMockData(expected)
    return true
end

function testPlaceMob()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.place = { false, true }
    mockData.expected.detect = { false }
    mockData.expected.attack = { true, false }
    local actual = turtle.place()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detect", "place", "attack", "attack", "place" }
    evaluateMockData(expected)
    return true
end

function testPlaceUp()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.placeUp = { true }
    mockData.expected.detectUp = { false }
    local actual = turtle.placeUp()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detectUp", "placeUp" }
    evaluateMockData(expected)
    return true
end

function testPlaceUpBlocked()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.detectUp = { true }
    local actual = turtle.placeUp()
    assert(not actual, "Expected false result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detectUp" }
    evaluateMockData(expected)
    return true
end

function testPlaceDown()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.placeDown = { true }
    mockData.expected.detectDown = { false }
    local actual = turtle.placeDown()
    assert(actual, "Expected true result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detectDown", "placeDown" }
    evaluateMockData(expected)
    return true
end

function testPlaceDownBlocked()
    init()
    local mockData = turtle.getMockData()
    mockData.expected.detectDown = { true }
    local actual = turtle.placeDown()
    assert(not actual, "Expected false result, actual: "..tostring(actual).." , turtle calls: "..stackToString(mockData.calls))
    local expected = { "detectDown" }
    evaluateMockData(expected)
    return true
end


--endregion

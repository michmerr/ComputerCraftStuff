-- region *.lua
-- Date
-- Mock terp

local mockData = { calls = { }; expected = { }; }
if not testCommon then
  os.loadAPI(testCommon)
end
testCommon.reloadAPI("turtle", "test/mocks/turtle")

local turnRightIndex = 0
function turtle.turnRight()
  turnRightIndex = turnRightIndex + 1
  table.insert(mockData.calls, "turnRight")
  return mockData.expected.turnRight[turnRightIndex]
end

local turnLeftIndex = 0
function turtle.turnLeft()
  turnLeftIndex = turnLeftIndex + 1
  table.insert(mockData.calls, "turnLeft")
  return mockData.expected.turnLeft[turnLeftIndex]
end

local digIndex = 0
function turtle.dig()
  digIndex = digIndex + 1
  table.insert(mockData.calls, "dig")
  return mockData.expected.dig[digIndex]
end

local digUpIndex = 0
function turtle.digUp()
  digUpIndex = digUpIndex + 1
  table.insert(mockData.calls, "digUp")
  return mockData.expected.digUp[digUpIndex]
end

local digDownIndex = 0
function turtle.digDown()
  digDownIndex = digDownIndex + 1
  table.insert(mockData.calls, "digDown")
  return mockData.expected.digUp[digDownIndex]
end

local detectIndex = 0
function turtle.detect()
  detectIndex = detectIndex + 1
  table.insert(mockData.calls, "detect")
  return mockData.expected.detect[detectIndex]
end

local detectUpIndex = 0
function turtle.detectUp()
  detectUpIndex = detectUpIndex + 1
  table.insert(mockData.calls, "detectUp")
  return mockData.expected.detectUp[detectUpIndex]
end

local detectDownIndex = 0
function turtle.detectDown()
  detectDownIndex = detectDownIndex + 1
  table.insert(mockData.calls, "detectDown")
  return mockData.expected.detectDown[detectDownIndex]
end

local detectRightIndex = 0
function turtle.detectRight()
  detectRightIndex = detectRightIndex + 1
  table.insert(mockData.calls, "detectRight")
  return mockData.expected.detectRight[detectRightIndex]
end

local detectLeftIndex = 0
function turtle.detectLeft()
  detectLeftIndex = detectLeftIndex + 1
  table.insert(mockData.calls, "detectLeft")
  return mockData.expected.detectLeft[detectLeftIndex]
end

local detectBackIndex = 0
function turtle.detectBack()
  detectBackIndex = detectBackIndex + 1
  table.insert(mockData.calls, "detectBack")
  return mockData.expected.detectBack[detectBackIndex]
end

local forwardIndex = 0
function turtle.forward()
  forwardIndex = forwardIndex + 1
  table.insert(mockData.calls, "forward")
  return mockData.expected.forward[forwardIndex]
end

local backIndex = 0
function turtle.back()
  backIndex = backIndex + 1
  table.insert(mockData.calls, "back")
  return mockData.expected.back[backIndex]
end

local reverseIndex = 0
function turtle.reverse()
  reverseIndex = reverseIndex + 1
  table.insert(mockData.calls, "reverse")
  return mockData.expected.reverse[reverseIndex]
end

local upIndex = 0
function turtle.up()
  upIndex = upIndex + 1
  table.insert(mockData.calls, "up")
  return mockData.expected.up[upIndex]
end

local downIndex = 0
function turtle.down()
  downIndex = downIndex + 1
  table.insert(mockData.calls, "down")
  return mockData.expected.down[downIndex]
end

local rightIndex = 0
function turtle.right(distance)
  rightIndex = rightIndex + 1
  table.insert(mockData.calls, "right")
  return mockData.expected.right[rightIndex]
end

local leftIndex = 0
function turtle.left(distance)
  leftIndex = leftIndex + 1
  table.insert(mockData.calls, "left")
  return mockData.expected.left[leftIndex]
end

function getMockData()
  return mockData;
end


-- endregion

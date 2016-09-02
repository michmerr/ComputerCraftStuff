-- region *.lua
-- Date
local mockData = { calls = { }; expected = { }; instances = { } }

function getMockData()
  return mockData
end

function create(...)
  local instanceMockData = { calls = { }; expected = { }; }
  local self = { }
  local args = { ...}
  self.attitude = args[1] or   {
            { 1; 0; 0 };
            { 0; 1; 0 };
            { 0; 0; 1 }
        }

  local getStateIndex = 0
  function self.getState()
    getStateIndex = getStateIndex + 1
    table.insert(instanceMockData.calls, "getState")
    return instanceMockData.expected.getState[getStateIndex]
  end

  local yawRightIndex = 0
  function self.yawRight()
    yawRightIndex = yawRightIndex + 1
    table.insert(instanceMockData.calls, "yawRight")
    return instanceMockData.expected.yawRight[yawRightIndex]
  end

  local yawLeftIndex = 0
  function self.yawLeft()
    yawLeftIndex = yawLeftIndex + 1
    table.insert(instanceMockData.calls, "yawLeft")
    return instanceMockData.expected.yawLeft[yawLeftIndex]
  end

  local pitchUpIndex = 0
  function self.pitchUp()
    pitchUpIndex = pitchUpIndex + 1
    table.insert(instanceMockData.calls, "pitchUp")
    return instanceMockData.expected.pitchUp[pitchUpIndex]
  end

  local pitchDownIndex = 0
  function self.pitchDown()
    pitchDownIndex = pitchDownIndex + 1
    table.insert(instanceMockData.calls, "pitchDown")
    return instanceMockData.expected.pitchDown[pitchDownIndex]
  end

  local rollRightIndex = 0
  function self.rollRight()
    rollRightIndex = rollRightIndex + 1
    table.insert(instanceMockData.calls, "rollRight")
    return instanceMockData.expected.rollRight[rollRightIndex]
  end

  local rollLeftIndex = 0
  function self.rollLeft()
    rollLeftIndex = rollLeftIndex + 1
    table.insert(instanceMockData.calls, "rollLeft")
    return instanceMockData.expected.rollLeft[rollLeftIndex]
  end

  local function translate(value)
    return value
  end

  local getFacingIndex = 0
  function self.getFacing()
    getFacingIndex = getFacingIndex + 1
    table.insert(instanceMockData.calls, "getFacing")
    return table.unpack(instanceMockData.expected.translateForward[getFacingIndex])
  end

  local translateForwardIndex = 0
  function self.translateForward()
    translateForwardIndex = translateForwardIndex + 1
    table.insert(instanceMockData.calls, "translateForward")
    return table.unpack(instanceMockData.expected.translateForward[translateForwardIndex])
  end

  local translateBackwardIndex = 0
  function self.translateBackward()
    translateBackwardIndex = translateBackwardIndex + 1
    table.insert(instanceMockData.calls, "translateBackward")
    return table.unpack(instanceMockData.expected.translateBackward[translateBackwardIndex])
  end

  local translateUpIndex = 0
  function self.translateUp()
    translateUpIndex = translateUpIndex + 1
    print("runtimeMockOrientationData" .. tostring(instanceMockData))
    table.insert(instanceMockData.calls, "translateUp")
    return table.unpack(instanceMockData.expected.translateUp[translateUpIndex])
  end

  local translateDownIndex = 0
  function self.translateDown()
    translateDownIndex = translateDownIndex + 1
    table.insert(instanceMockData.calls, "translateDown")
    return table.unpack(instanceMockData.expected.translateDown[translateDownIndex])
  end

  local translateLeftIndex = 0
  function self.translateLeft()
    translateLeftIndex = translateLeftIndex + 1
    table.insert(instanceMockData.calls, "translateLeft")
    return table.unpack(instanceMockData.expected.translateLeft[translateLeftIndex])
  end

  local translateRightIndex = 0
  function self.translateRight()
    translateRightIndex = translateRightIndex + 1
    table.insert(instanceMockData.calls, "translateRight")
    return table.unpack(instanceMockData.expected.translateRight[translateRightIndex])
  end

  function getMockData()
    return instanceMockData;
  end
  table.insert(mockData.calls, "create")
  table.insert(mockData.instances, instanceMockData)
  return self;
end


-- endregion

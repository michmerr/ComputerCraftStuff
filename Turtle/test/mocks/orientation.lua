-- region *.lua
-- Date
local mockData = { nextInstance = { }; calls = { }; expected = { }; instances = { } }
local simpleFunctions = { "getState", "yawRight", "yawLeft", "pitchUp", "pitchDown", "rollRight", "rollLeft", "getFacing" }
local unpackFunctions = { "translateForward", "translateBackward", "translateUp", "translateDown", "translateLeft", "translateRight" }

function getMockData()
  return mockData
end

local function simple(name, instanceData)
  instanceData.indices[name] = instanceData.indices[name] + 1
  table.insert(instanceData.calls, name)
  assert(instanceData.expected[name], "No calls to "..name.."() were expected.")
  assert(#instanceData.expected[name] >= instanceData.indices[name], string.format("Fewer calls (%d) were expected to %s.", #instanceData.expected[name], name))
  return instanceData.expected[name][instanceData.indices[name]]
end

function create(...)
  local instanceMockData = { calls = { }; expected = { }; indices = { } }
  if mockData.nextInstance and mockData.nextInstance.expected then
    instanceMockData.expected = mockData.nextInstance.expected
    mockData.nextInstance.expected = nil
  end

  local self = { }
  local args = { ... }
  self.attitude = args[1] or {
            { 1; 0; 0 };
            { 0; 1; 0 };
            { 0; 0; 1 }
        }

  assert(not args[1] or (type(args[1]) == "table" and #args[1] == 3), "Expected a nil or matrix table as create argument.")
  if args[1] then
    for i = 1, #args[1] do
      assert(args[1][i] and type(args[1][i]) == "table" and #args[1][i] == 3, "Expected 3-element list at row "..tostring(i))
    end
  end

  for i = 1, #simpleFunctions do
    local name = simpleFunctions[i]
    instanceMockData.indices[name] = 0
    self[name] =
      function()
        return simple(name, instanceMockData)
      end
  end

  for i = 1, #unpackFunctions do
    local name = unpackFunctions[i]
    instanceMockData.indices[name] = 0
    self[name] =
      function()
        return table.unpack(simple(name, instanceMockData))
      end
  end

  function getMockData()
    return instanceMockData;
  end
  table.insert(mockData.calls, "create")
  table.insert(mockData.instances, instanceMockData)
  return self;
end


-- endregion

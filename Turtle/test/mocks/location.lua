--region *.lua
--Date
if not testCommon then
  os.loadAPI("./testCommon")
end

testCommon.reloadAPI("orientation", "test/mocks/turtle")
testCommon.reloadAPI("orientation", "test/mocks/orientation")

local mockData = { calls = { }; expected = { }; indices = { create = 0 }; instances = { } }
local simpleFunctions = { "moveForward", "moveBack", "moveUp", "moveDown", "moveLeft", "moveRight", "getLocation", "howFar" }
local turtleFunctions = { "turnTo", "moveTo" }

function getMockData()
  return mockData
end

local function simple(name, instanceData, ...)
  instanceData.indices[name] = instanceData.indices[name] + 1
  local args= { ... }
  table.insert(instanceData.calls, #args > 0 and { name = name; args = args } or name)
  assert(instanceData.expected[name], "No calls to "..name.."() were expected.")
  assert(#instanceData.expected[name] >= instanceData.indices[name], "Fewer calls to "..name.."() were expected.")
  return instanceData.expected[name][instanceData.indices[name]]
end

function getMockLocationData(x, y, z, fX, fY, fZ)

  return {
    attitude = { { fX or 1, 0, 0 }, { 0, fY or 1, 0 }, { 0, 0, fZ or 1 } };
    x = x or 0;
    y = y or 0;
    z = z or 0
    }

end

function create(state)
  local instanceMockData = { calls = { }; expected = { }; indices = { } }
  local self = orientation.create(state and state.attitude)

  local x = state and state.x or 0
  local y = state and state.y or 0
  local z = state and state.z or 0

  for i = 1, #simpleFunctions do
    local name = simpleFunctions[i]
    instanceMockData.indices[name] = 0
    self[name] =
      function( ... )
        return simple(name, instanceMockData, ... )
      end
  end

  function getMockData()
    return instanceMockData;
  end
  mockData.indices.create = mockData.indices.create + 1
  table.insert(mockData.calls, "create")
  table.insert(mockData.instances, instanceMockData)
  return self;
end

local _location = create()


turtle.getLocation = _location.getLocation
turtle.howFar = _location.howFar
turtle.getFacing = _location.getFacing

for i = 1, #turtleFunctions do
  local name = turtleFunctions[i]
  mockData.indices[name] = 0
  turtle[name] =
    function( ... )
      return simple(name, mockData, ... )
    end
end


--endregion

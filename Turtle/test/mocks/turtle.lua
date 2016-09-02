local mockData = { calls = { }; expected = { }; indices = { } }

mockData.indices.forward = 0
function forward( )
mockData.indices.forward = mockData.indices.forward + 1
  table.insert(mockData.calls, "forward")
  return mockData.expected.forward[mockData.indices.forward]
end


mockData.indices.back = 0
function back( )
mockData.indices.back = mockData.indices.back + 1
  table.insert(mockData.calls, "back")
  return mockData.expected.back[mockData.indices.back]
end


mockData.indices.up = 0
function up( )
mockData.indices.up = mockData.indices.up + 1
  table.insert(mockData.calls, "up")
  return mockData.expected.up[mockData.indices.up]
end


mockData.indices.down = 0
function down( )
mockData.indices.down = mockData.indices.down + 1
  table.insert(mockData.calls, "down")
  return mockData.expected.down[mockData.indices.down]
end


mockData.indices.turnLeft = 0
function turnLeft( )
mockData.indices.turnLeft = mockData.indices.turnLeft + 1
  table.insert(mockData.calls, "turnLeft")
  return mockData.expected.turnLeft[mockData.indices.turnLeft]
end


mockData.indices.turnRight = 0
function turnRight( )
mockData.indices.turnRight = mockData.indices.turnRight + 1
  table.insert(mockData.calls, "turnRight")
  return mockData.expected.turnRight[mockData.indices.turnRight]
end


mockData.indices.dig = 0
function dig( )
mockData.indices.dig = mockData.indices.dig + 1
  table.insert(mockData.calls, "dig")
  return mockData.expected.dig[mockData.indices.dig]
end


mockData.indices.digUp = 0
function digUp( )
mockData.indices.digUp = mockData.indices.digUp + 1
  table.insert(mockData.calls, "digUp")
  return mockData.expected.digUp[mockData.indices.digUp]
end


mockData.indices.digDown = 0
function digDown( )
mockData.indices.digDown = mockData.indices.digDown + 1
  table.insert(mockData.calls, "digDown")
  return mockData.expected.digDown[mockData.indices.digDown]
end


mockData.indices.place = 0
function place( arg0 )
mockData.indices.place = mockData.indices.place + 1
  table.insert(mockData.calls, "place")
  return mockData.expected.place[mockData.indices.place]
end


mockData.indices.placeUp = 0
function placeUp( )
mockData.indices.placeUp = mockData.indices.placeUp + 1
  table.insert(mockData.calls, "placeUp")
  return mockData.expected.placeUp[mockData.indices.placeUp]
end


mockData.indices.placeDown = 0
function placeDown( )
mockData.indices.placeDown = mockData.indices.placeDown + 1
  table.insert(mockData.calls, "placeDown")
  return mockData.expected.placeDown[mockData.indices.placeDown]
end


mockData.indices.drop = 0
function drop( arg0 )
mockData.indices.drop = mockData.indices.drop + 1
  table.insert(mockData.calls, "drop")
  return mockData.expected.drop[mockData.indices.drop]
end


mockData.indices.select = 0
function select( arg0 )
mockData.indices.select = mockData.indices.select + 1
  table.insert(mockData.calls, "select")
  return mockData.expected.select[mockData.indices.select]
end


mockData.indices.getItemCount = 0
function getItemCount( arg0 )
mockData.indices.getItemCount = mockData.indices.getItemCount + 1
  table.insert(mockData.calls, "getItemCount")
  return mockData.expected.getItemCount[mockData.indices.getItemCount]
end

mockData.indices.getItemSpace = 0
function getItemSpace( arg0 )
mockData.indices.getItemSpace = mockData.indices.getItemSpace + 1
  table.insert(mockData.calls, "getItemSpace")
  return mockData.expected.getItemSpace[mockData.indices.getItemSpace]
end

mockData.indices.detect = 0
function detect( )
mockData.indices.detect = mockData.indices.detect + 1
  table.insert(mockData.calls, "detect")
  return mockData.expected.detect[mockData.indices.detect]
end


mockData.indices.detectUp = 0
function detectUp( )
mockData.indices.detectUp = mockData.indices.detectUp + 1
  table.insert(mockData.calls, "detectUp")
  return mockData.expected.detectUp[mockData.indices.detectUp]
end


mockData.indices.detectDown = 0
function detectDown( )
mockData.indices.detectDown = mockData.indices.detectDown + 1
  table.insert(mockData.calls, "detectDown")
  return mockData.expected.detectDown[mockData.indices.detectDown]
end


mockData.indices.compare = 0
function compare( )
mockData.indices.compare = mockData.indices.compare + 1
  table.insert(mockData.calls, "compare")
  return mockData.expected.compare[mockData.indices.compare]
end


mockData.indices.compareUp = 0
function compareUp( )
mockData.indices.compareUp = mockData.indices.compareUp + 1
  table.insert(mockData.calls, "compareUp")
  return mockData.expected.compareUp[mockData.indices.compareUp]
end


mockData.indices.compareDown = 0
function compareDown( )
mockData.indices.compareDown = mockData.indices.compareDown + 1
  table.insert(mockData.calls, "compareDown")
  return mockData.expected.compareDown[mockData.indices.compareDown]
end


mockData.indices.attack = 0
function attack( )
mockData.indices.attack = mockData.indices.attack + 1
  table.insert(mockData.calls, "attack")
  return mockData.expected.attack[mockData.indices.attack]
end


mockData.indices.attackUp = 0
function attackUp( )
mockData.indices.attackUp = mockData.indices.attackUp + 1
  table.insert(mockData.calls, "attackUp")
  return mockData.expected.attackUp[mockData.indices.attackUp]
end


mockData.indices.attackDown = 0
function attackDown( )
mockData.indices.attackDown = mockData.indices.attackDown + 1
  table.insert(mockData.calls, "attackDown")
  return mockData.expected.attackDown[mockData.indices.attackDown]
end


mockData.indices.dropUp = 0
function dropUp( arg0 )
mockData.indices.dropUp = mockData.indices.dropUp + 1
  table.insert(mockData.calls, "dropUp")
  return mockData.expected.dropUp[mockData.indices.dropUp]
end


mockData.indices.dropDown = 0
function dropDown( arg0 )
mockData.indices.dropDown = mockData.indices.dropDown + 1
  table.insert(mockData.calls, "dropDown")
  return mockData.expected.dropDown[mockData.indices.dropDown]
end


mockData.indices.suck = 0
function suck( )
mockData.indices.suck = mockData.indices.suck + 1
  table.insert(mockData.calls, "suck")
  return mockData.expected.suck[mockData.indices.suck]
end


mockData.indices.suckUp = 0
function suckUp( )
mockData.indices.suckUp = mockData.indices.suckUp + 1
  table.insert(mockData.calls, "suckUp")
  return mockData.expected.suckUp[mockData.indices.suckUp]
end


mockData.indices.suckDown = 0
function suckDown( )
mockData.indices.suckDown = mockData.indices.suckDown + 1
  table.insert(mockData.calls, "suckDown")
  return mockData.expected.suckDown[mockData.indices.suckDown]
end


mockData.indices.getFuelLevel = 0
function getFuelLevel( )
mockData.indices.getFuelLevel = mockData.indices.getFuelLevel + 1
  table.insert(mockData.calls, "getFuelLevel")
  return mockData.expected.getFuelLevel[mockData.indices.getFuelLevel]
end

mockData.indices.refuel = 0
function refuel( )
mockData.indices.refuel = mockData.indices.refuel + 1
  table.insert(mockData.calls, "refuel")
  return mockData.expected.refuel[mockData.indices.refuel]
end


mockData.indices.compareTo = 0
function compareTo( arg0 )
mockData.indices.compareTo = mockData.indices.compareTo + 1
  table.insert(mockData.calls, "compareTo")
  return mockData.expected.compareTo[mockData.indices.compareTo]
end


mockData.indices.transferTo = 0
function transferTo( arg0, arg1 )
mockData.indices.transferTo = mockData.indices.transferTo + 1
  table.insert(mockData.calls, "transferTo")
  return mockData.expected.transferTo[mockData.indices.transferTo]
end


mockData.indices.getSelectedSlot = 0
function getSelectedSlot( )
mockData.indices.getSelectedSlot = mockData.indices.getSelectedSlot + 1
  table.insert(mockData.calls, "getSelectedSlot")
  return mockData.expected.getSelectedSlot[mockData.indices.getSelectedSlot]
end

mockData.indices.getFuelLimit = 0
function getFuelLimit( )
mockData.indices.getFuelLimit = mockData.indices.getFuelLimit + 1
  table.insert(mockData.calls, "getFuelLimit")
  return mockData.expected.getFuelLimit[mockData.indices.getFuelLimit]
end

mockData.indices.equipLeft = 0
function equipLeft( )
mockData.indices.equipLeft = mockData.indices.equipLeft + 1
  table.insert(mockData.calls, "equipLeft")
  return mockData.expected.equipLeft[mockData.indices.equipLeft]
end


mockData.indices.equipRight = 0
function equipRight( )
mockData.indices.equipRight = mockData.indices.equipRight + 1
  table.insert(mockData.calls, "equipRight")
  return mockData.expected.equipRight[mockData.indices.equipRight]
end


mockData.indices.inspect = 0
function inspect( )
mockData.indices.inspect = mockData.indices.inspect + 1
  table.insert(mockData.calls, "inspect")
  return mockData.expected.inspect[mockData.indices.inspect]
end


mockData.indices.inspectUp = 0
function inspectUp( )
mockData.indices.inspectUp = mockData.indices.inspectUp + 1
  table.insert(mockData.calls, "inspectUp")
  return mockData.expected.inspectUp[mockData.indices.inspectUp]
end


mockData.indices.inspectDown = 0
function inspectDown( )
mockData.indices.inspectDown = mockData.indices.inspectDown + 1
  table.insert(mockData.calls, "inspectDown")
  return mockData.expected.inspectDown[mockData.indices.inspectDown]
end


mockData.indices.getItemDetail = 0
function getItemDetail( arg0 )
mockData.indices.getItemDetail = mockData.indices.getItemDetail + 1
  table.insert(mockData.calls, "getItemDetail")
  return mockData.expected.getItemDetail[mockData.indices.getItemDetail]
end

function resetMockData()
  mockData.calls = { }
  mockData.expected = { }
  for i = 1, #mockData.indices do
    mockData.indices[i] = 0
  end
end

function getMockData()
  return mockData;
end


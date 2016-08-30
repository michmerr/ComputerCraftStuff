local mockData = { calls = { }; expected = { }; }

local forwardIndex = 0
function forward( )
forwardIndex = forwardIndex + 1
  table.insert(mockData.calls, "forward")
  return mockData.expected.forward[forwardIndex]
end


local backIndex = 0
function back( )
backIndex = backIndex + 1
  table.insert(mockData.calls, "back")
  return mockData.expected.back[backIndex]
end


local upIndex = 0
function up( )
upIndex = upIndex + 1
  table.insert(mockData.calls, "up")
  return mockData.expected.up[upIndex]
end


local downIndex = 0
function down( )
downIndex = downIndex + 1
  table.insert(mockData.calls, "down")
  return mockData.expected.down[downIndex]
end


local turnLeftIndex = 0
function turnLeft( )
turnLeftIndex = turnLeftIndex + 1
  table.insert(mockData.calls, "turnLeft")
  return mockData.expected.turnLeft[turnLeftIndex]
end


local turnRightIndex = 0
function turnRight( )
turnRightIndex = turnRightIndex + 1
  table.insert(mockData.calls, "turnRight")
  return mockData.expected.turnRight[turnRightIndex]
end


local digIndex = 0
function dig( )
digIndex = digIndex + 1
  table.insert(mockData.calls, "dig")
  return mockData.expected.dig[digIndex]
end


local digUpIndex = 0
function digUp( )
digUpIndex = digUpIndex + 1
  table.insert(mockData.calls, "digUp")
  return mockData.expected.digUp[digUpIndex]
end


local digDownIndex = 0
function digDown( )
digDownIndex = digDownIndex + 1
  table.insert(mockData.calls, "digDown")
  return mockData.expected.digDown[digDownIndex]
end


local placeIndex = 0
function place( arg0 )
placeIndex = placeIndex + 1
  table.insert(mockData.calls, "place")
  return mockData.expected.place[placeIndex]
end


local placeUpIndex = 0
function placeUp( )
placeUpIndex = placeUpIndex + 1
  table.insert(mockData.calls, "placeUp")
  return mockData.expected.placeUp[placeUpIndex]
end


local placeDownIndex = 0
function placeDown( )
placeDownIndex = placeDownIndex + 1
  table.insert(mockData.calls, "placeDown")
  return mockData.expected.placeDown[placeDownIndex]
end


local dropIndex = 0
function drop( arg0 )
dropIndex = dropIndex + 1
  table.insert(mockData.calls, "drop")
  return mockData.expected.drop[dropIndex]
end


local selectIndex = 0
function select( arg0 )
selectIndex = selectIndex + 1
  table.insert(mockData.calls, "select")
  return mockData.expected.select[selectIndex]
end


local getItemCountIndex = 0
function getItemCount( arg0 )
getItemCountIndex = getItemCountIndex + 1
  table.insert(mockData.calls, "getItemCount")
  return mockData.expected.getItemCount[getItemCountIndex]
end

local getItemSpaceIndex = 0
function getItemSpace( arg0 )
getItemSpaceIndex = getItemSpaceIndex + 1
  table.insert(mockData.calls, "getItemSpace")
  return mockData.expected.getItemSpace[getItemSpaceIndex]
end

local detectIndex = 0
function detect( )
detectIndex = detectIndex + 1
  table.insert(mockData.calls, "detect")
  return mockData.expected.detect[detectIndex]
end


local detectUpIndex = 0
function detectUp( )
detectUpIndex = detectUpIndex + 1
  table.insert(mockData.calls, "detectUp")
  return mockData.expected.detectUp[detectUpIndex]
end


local detectDownIndex = 0
function detectDown( )
detectDownIndex = detectDownIndex + 1
  table.insert(mockData.calls, "detectDown")
  return mockData.expected.detectDown[detectDownIndex]
end


local compareIndex = 0
function compare( )
compareIndex = compareIndex + 1
  table.insert(mockData.calls, "compare")
  return mockData.expected.compare[compareIndex]
end


local compareUpIndex = 0
function compareUp( )
compareUpIndex = compareUpIndex + 1
  table.insert(mockData.calls, "compareUp")
  return mockData.expected.compareUp[compareUpIndex]
end


local compareDownIndex = 0
function compareDown( )
compareDownIndex = compareDownIndex + 1
  table.insert(mockData.calls, "compareDown")
  return mockData.expected.compareDown[compareDownIndex]
end


local attackIndex = 0
function attack( )
attackIndex = attackIndex + 1
  table.insert(mockData.calls, "attack")
  return mockData.expected.attack[attackIndex]
end


local attackUpIndex = 0
function attackUp( )
attackUpIndex = attackUpIndex + 1
  table.insert(mockData.calls, "attackUp")
  return mockData.expected.attackUp[attackUpIndex]
end


local attackDownIndex = 0
function attackDown( )
attackDownIndex = attackDownIndex + 1
  table.insert(mockData.calls, "attackDown")
  return mockData.expected.attackDown[attackDownIndex]
end


local dropUpIndex = 0
function dropUp( arg0 )
dropUpIndex = dropUpIndex + 1
  table.insert(mockData.calls, "dropUp")
  return mockData.expected.dropUp[dropUpIndex]
end


local dropDownIndex = 0
function dropDown( arg0 )
dropDownIndex = dropDownIndex + 1
  table.insert(mockData.calls, "dropDown")
  return mockData.expected.dropDown[dropDownIndex]
end


local suckIndex = 0
function suck( )
suckIndex = suckIndex + 1
  table.insert(mockData.calls, "suck")
  return mockData.expected.suck[suckIndex]
end


local suckUpIndex = 0
function suckUp( )
suckUpIndex = suckUpIndex + 1
  table.insert(mockData.calls, "suckUp")
  return mockData.expected.suckUp[suckUpIndex]
end


local suckDownIndex = 0
function suckDown( )
suckDownIndex = suckDownIndex + 1
  table.insert(mockData.calls, "suckDown")
  return mockData.expected.suckDown[suckDownIndex]
end


local getFuelLevelIndex = 0
function getFuelLevel( )
getFuelLevelIndex = getFuelLevelIndex + 1
  table.insert(mockData.calls, "getFuelLevel")
  return mockData.expected.getFuelLevel[getFuelLevelIndex]
end

local refuelIndex = 0
function refuel( )
refuelIndex = refuelIndex + 1
  table.insert(mockData.calls, "refuel")
  return mockData.expected.refuel[refuelIndex]
end


local compareToIndex = 0
function compareTo( arg0 )
compareToIndex = compareToIndex + 1
  table.insert(mockData.calls, "compareTo")
  return mockData.expected.compareTo[compareToIndex]
end


local transferToIndex = 0
function transferTo( arg0, arg1 )
transferToIndex = transferToIndex + 1
  table.insert(mockData.calls, "transferTo")
  return mockData.expected.transferTo[transferToIndex]
end


local getSelectedSlotIndex = 0
function getSelectedSlot( )
getSelectedSlotIndex = getSelectedSlotIndex + 1
  table.insert(mockData.calls, "getSelectedSlot")
  return mockData.expected.getSelectedSlot[getSelectedSlotIndex]
end

local getFuelLimitIndex = 0
function getFuelLimit( )
getFuelLimitIndex = getFuelLimitIndex + 1
  table.insert(mockData.calls, "getFuelLimit")
  return mockData.expected.getFuelLimit[getFuelLimitIndex]
end

local equipLeftIndex = 0
function equipLeft( )
equipLeftIndex = equipLeftIndex + 1
  table.insert(mockData.calls, "equipLeft")
  return mockData.expected.equipLeft[equipLeftIndex]
end


local equipRightIndex = 0
function equipRight( )
equipRightIndex = equipRightIndex + 1
  table.insert(mockData.calls, "equipRight")
  return mockData.expected.equipRight[equipRightIndex]
end


local inspectIndex = 0
function inspect( )
inspectIndex = inspectIndex + 1
  table.insert(mockData.calls, "inspect")
  return mockData.expected.inspect[inspectIndex]
end


local inspectUpIndex = 0
function inspectUp( )
inspectUpIndex = inspectUpIndex + 1
  table.insert(mockData.calls, "inspectUp")
  return mockData.expected.inspectUp[inspectUpIndex]
end


local inspectDownIndex = 0
function inspectDown( )
inspectDownIndex = inspectDownIndex + 1
  table.insert(mockData.calls, "inspectDown")
  return mockData.expected.inspectDown[inspectDownIndex]
end


local getItemDetailIndex = 0
function getItemDetail( arg0 )
getItemDetailIndex = getItemDetailIndex + 1
  table.insert(mockData.calls, "getItemDetail")
  return mockData.expected.getItemDetail[getItemDetailIndex]
end

function getMockData()
  return mockData;
end


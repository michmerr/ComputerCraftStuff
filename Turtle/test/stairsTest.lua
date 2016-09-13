--region *.lua
--Date
if not testCommon then
  os.loadAPI("./testCommon")
end

testCommon.reloadAPI("terp", "test/mocks/terp")
testCommon.reloadAPI("location", "test/mocks/location")
testCommon.reloadAPI("matrix", "matrix")

--region job test
function testCreateJob(treadWidth, treadDepth, height, maxLength, maxWidth, measureOutside, clockwise, materialSlotRangeLow, materialSlotRangeHigh, materialTypes, intervalActions)
  assert(false, "TODO")

end

function testsetDirections()
  assert(false, "TODO")


end

function testisFacingNext()
  assert(false, "TODO")


end

function testisFacingEdge()
  assert(false, "TODO")


end

function testisFacingWall()
  assert(false, "TODO")


end

function testisFacingLast()
  assert(false, "TODO")


end

function testisOnWall()
  assert(false, "TODO")


end

function testisOnEdge()
  assert(false, "TODO")


end

function testInitialize()
  assert(false, "TODO")


end
--endregion

--region stairs tests

--endregion

--endregion

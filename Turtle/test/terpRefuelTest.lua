--region *.lua

if not testCommon then
  os.loadAPI("/terp/lib/./testCommon")
end

function init()
  testCommon.reloadAPI("terp", "test/mocks/terp")
  testCommon.reloadAPI("location", "test/mocks/location")
  testCommon.reloadAPI("waypointCollection", "test/mocks/waypointCollection")

  -- Default refuel point getting set to current position - 180 degrees
  location.getMockData().expected.getLocation = { location.getMockLocationData() }
  orientation.getMockData().nextInstance.expected = { yawRight = { true, true } }

  testCommon.reloadAPI("terpRefuel", "terpRefuel")
end

function testDummy()
  init()
  assert(false, "TODO")
end


--endregion

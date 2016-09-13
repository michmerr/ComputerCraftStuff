--region *.lua
--Date

if not testCommon then
  os.loadAPI("./testCommon")
end

testCommon.reloadAPI("ConsoleLogger","/terp/ConsoleLogger")

function testDefaultLog()

  local target = ConsoleLogger.new()
  target.log(Logger.levels.DEBUG, "Test message")

end



--endregion

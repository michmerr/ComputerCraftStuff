--region *.lua
--Date

if not Logger then
  os.loadAPI("/terp/lib/Logger")
end
if not ConsoleLogger then
  os.loadAPI("/terp/lib/ConsoleLogger")
end

local listener = ConsoleLogger.new()
local logger = Logger.new()
table.insert(logger.listeners, listener)
Logger.setGlobalLogger(logger)

function reloadAPI(checkApi, loadApi)

    if _G[checkApi] then
        os.unloadAPI(checkApi)
    end

    os.loadAPI(loadApi)

end


--endregion

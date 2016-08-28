--region *.lua
--Date

function reloadAPI(checkApi, loadApi)

    if _G[checkApi] then
        os.unloadAPI(checkApi)
    end

    os.loadAPI(loadApi)

end


--endregion

--region *.lua
--Date

function reloadAPI(checkApi, loadApi)

    if _G[checkApi] then
        os.unloadAPI(checkApi)
    end

    if not package then
      loadApi = "/terp/"..loadApi
    end
    os.loadAPI(loadApi)

end


--endregion

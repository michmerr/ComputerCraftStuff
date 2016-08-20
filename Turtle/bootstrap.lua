--region *.lua
--Date

local files = {
    { id = "mJUmapaU"; filename = "compactor" };
    { id = "ujCGgT4B"; filename = "emod" };
    { id = "fVQkNm3s"; filename = "itemType" };
    { id = "eeW1P5yn"; filename = "itemTypeCollection" };
    { id = "0HTvSbnR"; filename = "location" };
    { id = "XtKPTr8w"; filename = "matrix" };
    { id = "bjL3qwT3"; filename = "orientation" };
    { id = "QbDGxCFk"; filename = "stairs" };
    { id = "Fn6CwVeP"; filename = "terp" };
    { id = "3ybYj83v"; filename = "terpCommands" };
    { id = "WSzxwE6M"; filename = "terpRefuel" };
    { id = "vSS87WCN"; filename = "utilities" };
    { id = "fSGbj0CL"; filename = "waypoint" };
    { id = "10MYnVY2"; filename = "waypointCollection" };
}

local args = { ... }

if args[1] and args[1] == "exec" then
    for file in files do
        if (fs.exists(file.filename)) then
            fs.delete(file.filename)
        end
        shell.run("pastebin", "get", file.id, file.filename)
    end
else

    if (fs.exists("_bootstrap.lua")) then
        fs.delete("_bootstrap.lua")
    end

    shell.run("pastebin", "get", "FDLJGt19", "_bootstrap.lua")
    shell.run("_bootstrap.lua", "exec")

end




--endregion

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
    for i = 1, #files do
        if (fs.exists(files[i].filename)) then
            fs.delete(files[i].filename)
        end
        shell.run("pastebin", "get", files[i].id, files[i].filename)
    end
else

    if (fs.exists("_bootstrap")) then
        fs.delete("_bootstrap")
    end

    shell.run("pastebin", "get", "FDLJGt19", "_bootstrap")
    shell.run("_bootstrap", "exec")

end




--endregion

-- region *.lua
-- Date
local githubUrl = "https://raw.githubusercontent.com/michmerr/ComputerCraftStuff/master/Turtle"

local files = {
  "/test/consoleLoggerTest";
  "/test/inventoryTest";
  "/test/locationTest";
  "/test/orientationTest";
  "/test/stairsTest";
  "/test/terpCommandsTest";
  "/test/terpRefuelTest";
  "/test/terpTest";
  "/test/test";
  "/test/testCommon";
  "/test/waypointsTest";
  "/test/mocks/location";
  "/test/mocks/orientation";
  "/test/mocks/terp";
  "/test/mocks/turtle";
  "/test/mocks/waypointCollection";
  "/bootstrap";
  "/compactor";
  "/ConsoleLogger";
  "/e2";
  "/FileLogger";
  "/inventory";
  "/itemType";
  "/itemTypeCollection";
  "/itemTypeData";
  "/location";
  "/Logger";
  "/LogListener";
  "/matrix";
  "/orientation";
  "/stairs";
  "/terp";
  "/terpCommands";
  "/terpRefuel";
  "/transfer";
  "/utilities";
  "/waypoint";
  "/waypointCollection";
}

-- grafting in wget code, since CC under MC 1.7.10 doesn't have it in the ROM, and this is the bootstrapper...
local function get( sUrl )
    local ok, err = http.checkURL( sUrl )
    if not ok then
        write( "Invalid url" )
        if err then
            print( ": "..err )
        end
        return nil
    end

    local response = http.get( sUrl )
    if not response then
        print( "Get failed for "..tostring(sUrl) )
        return nil
    end

    local sResponse = response.readAll()
    response.close()
    return sResponse
end

local function wget(sUrl, sFile)
  local sPath = shell.resolve( sFile )
  if fs.exists( sPath ) then
    if fs.isDir( sPath) then
      print("Local filepath points to an existing DIRECTORY.")
      return nil
    end
    fs.delete( sPath)
  elseif not fs.exists( fs.getDir(sPath) ) then
    fs.makeDir(fs.getDir(sPath))
  end

  -- Do the get
  local res = get( sUrl )
  if res then
      local file = fs.open( sPath, "w" )
      file:write( res )
      file:close()
      return true
  end
  return nil
end

local function updateBootstrapper()
  write("Updating bootstrapper...")
  if wget(githubUrl.."/bootstrap.lua", "/_bootstrap") then
    print("ok")
    return true
  else
    print("failed")
    return nil
  end
end

local function pull()
  local pass = 0
  local fail = 0
  for i = 1, #files do
    local localPath = "/terp"..files[i]
    local fileUrl = githubUrl..files[i]..".lua"
    write(localPath.."...")
    if wget(fileUrl, localPath) then
      pass = pass + 1
      print("ok")
    else
      fail = fail + 1
      print("failed")
    end
  end
  print(string.format("Files updated successfully: %d", pass))
  if (fail > 0) then
    print(string.format("File updates failed: %d", fail))
  end
end

local args = { ...}

if args[1] and args[1] == "exec" then
  pull()
else
  if updateBootstrapper() then
    print("Executing updated bootstrapper...")
    shell.run("/_bootstrap", "exec")
  else
    print("Aborting bootstrapper.")
  end
end




-- endregion

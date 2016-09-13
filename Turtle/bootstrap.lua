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

local args = { ...}

if args[1] and args[1] == "exec" then
  for i = 1, #files do
    if (fs.exists(files[i])) then
      fs.delete(files[i])
    end
    local dir = fs.combine("/terp", fs.getDir(files[i]))
    if not fs.exists(dir) then
      fs.makeDir(dir)
    end
    shell.setDir(dir)
    shell.run("wget", githubUrl..files[i]..".lua", fs.getName(files[i]))
  end
else

  if (fs.exists("_bootstrap")) then
    fs.delete("_bootstrap")
  end

  shell.run("wget", githubUrl.."/bootstrap.lua", "/_bootstrap")
  shell.run("/_bootstrap", "exec")

end




-- endregion

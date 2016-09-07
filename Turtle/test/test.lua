-- region *.lua
local root = ".."
if not fs then
  package.path = package.path .. ";../?;../?.lua;../rom/apis/?;../rom/apis/?.lua;../rom/apis/turtle/?;../rom/apis/turtle/?.lua"

  dofile("../rom/apis/fs.lua")
  dofile("../rom/apis/os.lua")
else
  root = "/terp"
end

os.loadAPI(fs.combine(root, "test/testCommon"))
testCommon.reloadAPI("turtle", "test/mocks/turtle")

local detailed, quiet
local args = { ...}
local filespec = "./*"
for i = 1, #args do
  if string.sub(args[i], 1, 1) == "-" then
    local switch = string.lower(string.sub(args[i], 2))
    while string.sub(switch, 1, 1) == "-" do
      switch = string.sub(switch, 2)
    end
    if switch == "detailed" or switch == "d" or switch == "v" or switch == "verbose" then
      detailed = true
    elseif switch == "q" or switch == "quiet" then
      quiet = true
    end
  else
    filespec = args[i]
  end
end

assert(not(detailed and quiet), "Pick one, detailed or quiet; you can't have it both ways.")

local files = fs.find(fs.combine(root, filespec))
local results = { }
local totals = { }

for i = 1, #files do
  local api = fs.getName(files[i])
  if not fs.isDir(files[i]) and not(api == "test" or api == "test.lua" or api == "testCommon" or api == "testCommon.lua") then
    print("Testing: " .. api)
    os.loadAPI(files[i])
    local testTable = _G[api]
    -- for k,v in pairs(_G) do print(k) end
    local maxlength = 0
    totals[api] = { passed = 0; failed = 0 }
    for name, func in pairs(testTable) do
      if string.sub(name, 1, 4) == "test" then
        local namelength = string.len(name)
        if namelength > maxlength then
          maxlength = namelength
        end
      end
    end
    for name, func in pairs(testTable) do
      if string.sub(name, 1, 4) == "test" then
        local result, err = pcall(func)
        if not result then
          totals[api].failed = totals[api].failed + 1
        else
          totals[api].passed = totals[api].passed + 1
        end

        if detailed or not result then
          print(string.format("  %s%s [%s]%s", name, string.rep(" ", maxlength - string.len(name)), result and "passed" or "FAILED", result and "" or ": " .. err))
        end
      end
    end

    print(string.format("  passed: %d", totals[api].passed))
    if totals[api].failed > 0 then
      print(string.format("  failed: %d", totals[api].failed))
    end
    print("")
    os.unloadAPI(api)
  end
end

local passed = 0
local failed = 0
for k, v in pairs(totals) do
  passed = passed + v.passed
  failed = failed + v.failed
end

print(string.format("passed: %d", passed))

if (failed > 0) then
  print(string.format("failed: %d", failed))
end


-- endregion

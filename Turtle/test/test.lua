--region *.lua
package.path = package.path..";../?;../?.lua;../rom/apis/?;../rom/apis/?.lua;../rom/apis/turtle/?;../rom/apis/turtle/?.lua"
if not fs then
  dofile("../rom/apis/fs.lua")
  dofile("../rom/apis/os.lua")
end

os.loadAPI("testCommon")
testCommon.reloadAPI("turtle", "test/mocks/turtle")

local args = { ... }
local filespec = "./*"
if #args > 0 then
    filespec = args[1]
end
local files = fs.find(filespec)
local results = {}
local totals = {}

for i=1, #files do
    local api = fs.getName(files[i])
    if not(api == "test" or api == "test.lua" or api == "testCommon" or api == "testCommon.lua") then
      os.loadAPI(files[i])
      local testTable = _G[api]
      print("Testing: "..api)
      --for k,v in pairs(_G) do print(k) end
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

              print(string.format("  %s%s [%s]%s", name, string.rep(" ", maxlength - string.len(name)), result and "passed" or "FAILED", result and "" or ": "..err))
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
for k,v in pairs(totals) do
    passed = passed + v.passed
    failed = failed + v.failed
end

print(string.format("passed: %d", passed))

if (failed > 0) then
    print(string.format("failed: %d", failed))
end


--endregion

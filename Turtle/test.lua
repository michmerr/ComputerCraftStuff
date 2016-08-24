--region *.lua

local files = fs.find("locationTest*")
local results = {}
local totals = {}
for i=1, #files do

    os.loadAPI(files[i])
    local testTable = _G[files[i]]
    local maxlength = 0
    print (files[i])
    totals[files[i]] = { passed = 0; failed = 0 }
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
                totals[files[i]].failed = totals[files[i]].failed + 1
            else
                totals[files[i]].passed = totals[files[i]].passed + 1
            end

            print(string.format("  %s%s [%s]%s", name, string.rep(" ", maxlength - string.len(name)), result and "passed" or "FAILED", result and "" or ": "..err))
        end
    end

    print(string.format("  passed: %d", totals[files[i]].passed))
    if totals[files[i]].failed > 0 then
        print(string.format("  failed: %d", totals[files[i]].failed))
    end
    print("")
    os.unloadAPI(files[i])
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

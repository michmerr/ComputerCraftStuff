--region *.lua
--Date

if not turtle then
    require("turtle")
end

function create()
    local self = {}

    -- This can be used to add extensions to this instance.
    -- The instance itself can be extended directly as well. In cases where before_ after_ functions are
    -- being added, and a simple append of the extension functions to the existing list is not what is desired,
    -- direct manipulation of those tables would be required.

    function self.extend(table)
        for k, v in pairs(table) do
            if (k.sub(0, 6) == "before_" or k.sub(0, 5) == "after_") then
                if not self[k] then
                    self[k] = { }
                end

                if type(v) == "table" then
                    for f in v do
                        print(string.format("Adding function %s to Terp instance %s list...\n", tostring(f), k))
                        table.insert(self[k], f)
                    end
                else
                    print(string.format("Adding function %s to Terp instance %s list...\n", tostring(v), k))
                    table.insert(self[k], v)
                end
            else
                print(string.format("Adding function %s to Terp instance...\n", k))
                self[k] = v
            end
        end
    end

    -- Extend turtle
    self.extend(turtle)

    local function noneFail(func)
        if not func then
            return true
        end

        -- Call either a list of functions or a standalone.
        if type(func) == "function" then
            return func()
        end

        for f = 1, #func do
            if not func[f]() then
                return false
            end
        end
        return true
    end

    local function anySucceed(func)
        if not func then
            return false
        end

        -- Call either a list of functions or a standalone.
        if type(func) == "function" then
            return func()
        end

        for f = #func, 1 do
            if func[f]() then
                return true
            end
        end
        return false
    end

    local function tryAction(funcs, remedialFuncs)
        -- if any of the functions fail, attempt remedial action
        if not noneFail(funcs) then
            -- fail if none of the remedial actions fail or if any the pre-req functions still fail
            if not anySucceed(remedialFuncs) then
                return false
            end
        end

        return noneFail(funcs)
    end

    local function tryDecoratedAction(funcName, func)
        assert(funcName and type(funcName) == "string", "Expected funcName to be a string")
        assert(func and type(func) == "function" or turtle[funcName], "Expected func to be a function or funcName to be a valid turtle function name.")

        if not func then
            func = turtle[funcName]
        end

        if not tryAction(self["before_"..funcName], self["onFail_before_"..funcName]) then
            return false
        end
        if not tryAction(func, self["onFail_"..funcName]) then
            return false
        end
        if not tryAction(self["after_"..funcName], self["onFail_after"..funcName]) then
            return false
        end
        return true
    end

    local function repeatDecoratedAction(funcName, func, count)
        if not count then
            count = 1
        end

        for i = 1, count do
            if not tryDecoratedAction(funcName, func) then
                return false
            end
        end
        return true
    end

    local function digUntil(digFunc, detectFunc)

        if not detectFunc() or not digFunc() then
            return false
        end

        local result = true
        os.sleep(0.6);
        while detectFunc() do
            os.sleep(0.6)
            result = digFunc()
        end
        return result

    end

    function self.turnAround()
        return self.turnRight() and self.turnRight()
    end

    -- digUp will perform tasks required to dig through gravel/sand. Additiona before/actions
    -- can be added as decorator for execution around digUntil.
    function self.dig()
        return tryDecoratedAction("dig", function() return digUntil(turtle.dig, self.detect) end)
    end

    function self.digUp()
        return tryDecoratedAction("digUp", function() return digUntil(turtle.digUp, self.detectUp) end)
    end

    -- Different than up and forward in that sand or gravel won't fall to fill the gap
    function self.digDown()
        return detectDown() and tryDecoratedAction("digDown")
    end

    function self.detectRight()
        self.turnRight()
        local result = self.detect()
        self.turnLeft()
        return result
    end

    function self.detectLeft()
        self.turnLeft()
        local result = self.detect()
        self.turnRight()
        return result
    end

    function self.detectBack()
        self.turnAround()
        local result = self.detect()
        self.turnAround()
        return result
    end

    -- Clear the way for movement
    function self.probe()
        return not self.detect() or self.dig()
    end

    function self.probeUp()
        return not self.detectUp() or self.digUp()
    end

    function self.probeDown()
        return not self.detectDown() or self.digDown()
    end

    -- Initialize list of functions to run before and after basic commands.
    -- e.g. detect before forward.
    -- Allows
    for direction in { "Up", "Down", "Forward" } do
        self["before_"..direction.lower] = { self["probe"..direction] }
    end

    function self.forward(distance)
        return repeatDecoratedAction("forward", distance)
    end

    function self.back(distance)
        return repeatDecoratedAction("back", distance)
    end

    function self.reverse(distance)
        self.turnLeft()
        self.turnLeft()
        local result = self.forward(distance)
        self.turnLeft()
        self.turnLeft()
        return result
    end

    function self.up(distance)
        return repeatDecoratedAction("up", distance)
    end

    function self.down(distance)
        return repeatDecoratedAction("down", distance)
    end

    function self.right(distance)
        self.turnRight()
        local result = self.forward(distance)
        self.turnLeft()
        return result;
    end

    function self.left(distance)
        self.turnLeft()
        local result = self.forward(distance)
        self.turnRight()
        return result;
    end

    return self
end
--endregion
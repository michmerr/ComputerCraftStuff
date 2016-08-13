--region *.lua
--Date

if not location then
    require("location")
end

if not turtle then
    require("turtle")
end

if not terp then
    terp = {}
end

function terp.create()
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

    function self.dig()
        while self.detect() do
            turtle.dig()
        end
    end

    function self.digUp()
        while self.detectUp() do
            turtle.digUp()
        end
    end

    function self.detectRight()
        turtle.turnRight()
        local result = self.detect()
        turtle.turnLeft()
        return result
    end

    function self.detectLeft()
        turtle.turnLeft()
        local result = self.detect()
        turtle.turnRight()
        return result
    end

    function self.detectBack()
        turtle.turnLeft()
        turtle.turnLeft()
        local result = self.detect()
        turtle.turnRight()
        turtle.turnRight()
        return result
    end

    for direction in { "Up", "Down", "Forward" } do
        self["before_"..direction.lower] = { self["dig"..direction] }
    end

    local function _if_call(func)
        if (not func or (type(func) == "table" and #func == 0)) then
            return true
        end

        -- Call either a list of functions or a standalone.
        if (type(func) == "table") then
            for f in func do
                if not f() then
                    return false
                end
            end
            return true
        end

        return func()
    end

    local function _repeat_set(funcName, count)
        if not _if_call(self["before_all_"..funcName]) then
            return false
        end
        for i = 1, count do
            if not ( _if_call(self["before_"..funcName]) and _if_call(turtle[funcName]) and _if_call(self["after_"..funcName]) ) then
                return false
            end
        end
        return _if_call(self["after_all_"..funcName])
    end

    function self.forward(distance)
        return _wrap_set("forward", distance)
    end

    function self.back(distance)
        return _wrap_set("back", distance)
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
        return _repeat_set("up", distance)
    end

    function self.down(distance)
        return _repeat_set("down", distance)
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
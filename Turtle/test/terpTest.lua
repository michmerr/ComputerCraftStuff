--region *.lua
--Date
--region *.lua
--Date

if not testCommon then
    os.loadAPI("test/testCommon")
end

testCommon.reloadAPI("turtle", "test/mocks/turtle")
testCommon.reloadAPI("terp", "test/mocks/turtle")

function testCreate()
    local target = terp.create()
    assert(target, "Expected a non-nil object")
    return true
end


function testExtendsTurtle()
    local target = terp.create()
    assert(target.forward and target.inspect == turtle.inspect)
end

function testExtend()
    local target = terp.create()
    local extensions = {
        testExt = function() print("test") end;
        before_forward = function() print("foo") end;
        after_forward = { function() print("after") end; }
    }

    target.extend(extensions)

    assert(target.testExt, "Did not find expected extension function testExt")
    assert(target.before_forward and type(target.before_forward) == "table" and target.before_forward[#target.before_forward] == extensions.before_forward,
        "Did not find before_forward added to the terp before_forward list")
    assert(target.after_forward and type(target.after_forward) == "table" and target.after_forward[#target.after_forward] == extensions.after_forward,
        "Did not find after_forward added to the terp before_forward list")


--        for k, v in pairs(table) do
--            if (k.sub(0, 6) == "before_" or k.sub(0, 5) == "after_") then
--                if not self[k] then
--                    self[k] = { }
--                end

--                if type(v) == "table" then
--                    for f in v do
--                        print(string.format("Adding function %s to Terp instance %s list...\n", tostring(f), k))
--                        table.insert(self[k], f)
--                    end
--                else
--                    print(string.format("Adding function %s to Terp instance %s list...\n", tostring(v), k))
--                    table.insert(self[k], v)
--                end
--            else
--                print(string.format("Adding function %s to Terp instance...\n", k))
--                self[k] = v
--            end
--        end
end


--    local function digUntil(digFunc, detectFunc)
--        if not detectFunc() then
--            return false
--        end

--        local result = digFunc()
--        while detectFunc() do
--            os.sleep(0.5)
--            result = digFunc()
--        end
--        return result

--    end
function testDig()
        return digUntil(turtle.dig, self.detect)
    end

    function probe()
        self.dig()
        return not self.detect()
    end
function testDigUp()
        return digUntil(turtle.digUp, self.detectUp)
    end

--    function probeUp()
--        self.digUp()
--        return not self.detectUp()
--    end

function testDigDown()
        local result = false
        if self.detectDown() then
            result = turtle.digDown()
        end
        return result
    end

function testProbe()

end

function testProbeDown()
end


function testProbeUp()
end

function testDetectRight()
        turtle.turnRight()
        local result = self.detect()
        turtle.turnLeft()
        return result
    end
function testDetectLeft()
        turtle.turnLeft()
        local result = self.detect()
        turtle.turnRight()
        return result
    end
function testDetectBack()
        turtle.turnLeft()
        turtle.turnLeft()
        local result = self.detect()
        turtle.turnRight()
        turtle.turnRight()
        return result
    end

function testForward(distance)
        return _repeat_set("forward", distance)
    end
function testBack(distance)
        return _repeat_set("back", distance)
    end
function testReverse(distance)
        self.turnLeft()
        self.turnLeft()
        local result = self.forward(distance)
        self.turnLeft()
        self.turnLeft()
        return result
    end
function testUp(distance)
        return _repeat_set("up", distance)
    end
function testDown(distance)
        return _repeat_set("down", distance)
    end
function testRight(distance)
        self.turnRight()
        local result = self.forward(distance)
        self.turnLeft()
        return result;
    end
function testLeft(distance)
        self.turnLeft()
        local result = self.forward(distance)
        self.turnRight()
        return result;
    end

--endregion

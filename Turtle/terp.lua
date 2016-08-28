--region *.lua
--Date

if not turtle then
    require("turtle")
end

function create()
    local self = {}

    function self.turnAround()
        return self.turnRight() and self.turnRight()
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

    local function move(moveFunc, detectFunc, digFunc, attackFunc)
        if detectFunc() then
            if not digFunc() then
                return false
            end
        end
        while not moveFunc() do
            if detectFunc() then
                if not digFunc() then
                    return false
                end
            elseif not attackFunc() then
                -- falling block after previous dig
                os.sleep(0.2)
            end
        end
    end

    function self.forward()
        return move(turtle.forward, turtle.detect, turtle,dig, turtle.attack)
    end

    function self.back()
        local result = turtle.back()
        if not result then
            self.turnAround()
            result = self.forward()
            self.turnAround()
        end
        return result;
    end

    function self.up()
        return move(turtle.up, turtle.detectUp, turtle,digUp, turtle.attackUp)
    end

    function self.down()
        return move(turtle.down, turtle.detectDown, turtle,digDown, turtle.attackDown)
    end

    function self.right(distance)
        local result = true
        self.turnRight()
        for i = 1, distance or 1 do
            if not self.forward() then
                result = false
                break
            end
        end
        self.turnLeft()
        return result;
    end

    function self.left(distance)
        local result = true
        self.turnLeft()
        for i = 1, distance or 1 do
            if not self.forward() then
                result = false
                break
            end
        end
        self.turnRight()
        return result;
    end

    -- Extend turtle
    for k, v in pairs(turtle) do
        if not self[k] then
            self[k] = v
        end
    end

    return self
end
--endregion
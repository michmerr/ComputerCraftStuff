--region *.lua
--Date

if not orientation then
    os.loadAPI("orientation")
end

function create(state)

    local self = orientation.create(state and state.attitude)

    local x = state and state.x or 0
    local y = state and state.y or 0
    local z = state and state.z or 0

    local function move(dx, dy, dz)
        x = x + dx
        y = y + dy
        z = z + dz
        return self.getLocation()
    end

    function self.moveForward()
        return move(self.translateForward())
    end

    function self.moveBack()
        return move(self.translateBackward())
    end

    function self.moveUp()
       return  move(self.translateUp())
    end

    function self.moveDown()
       return  move(self.translateDown())
    end

    function self.moveLeft()
        return move(self.translateLeft())
    end

    function self.moveRight()
        return move(self.translateRight())
    end

    function self.getLocation()
        return { ["x"] = x; ["y"] = y; ["z"] = z; }
    end

    -- Distance to coords in right-angle moves
    function self.howFar(x1, y1, z1)
        return math.abs(x - x1) + math.abs(y - y1) + math.abs(z - z1)
    end

    return self
end

function decorate(targetTerp)

    local _location = create()

    local function wrapMovementFunction(wrapFunc, locFunc)
        return function(...)
            local result = wrapFunc(...)
            if result then
                locFunc()
            end
            return result
       end
    end

    for direction in { "Up", "Down", "Forward", "Back" } do
        local funcName = direction.lower
        targetTerp[funcName] = wrapMovementFunction(targetTerp[funcName], _location["move"..direction])
    end

    for direction in { "turnRight", "Left" } do
        targetTerp[direction] = wrapMovementFunction(targetTerp[direction], _location[direction])
    end

    targetTerp.getLocation = _location.getLocation
    targetTerp.howFar = _location.howFar

    function turnTo(x, z)
        if math.abs(x) == math.abs(y) then
            error("90 degree directions only. One value must be 0, and the other must be positive or negative to indicate the facing along that axis.")
        end

        local facing = _location.translateForward()

        if (z < 0) then
            if facing[1] > 0 then
                targetTerp.turnRight()
            elseif facing[1] < 0 then
                targetTerp.turnLeft()
            elseif facing[3] > 0 then
                targetTerp.turnRight()
                targetTerp.turnRight()
            end
        elseif (z > 0) then
            if facing[1] == 1 then
                targetTerp.turnLeft()
            elseif facing[1] == -1 then
                targetTerp.turnRight()
            elseif facing[3] < 0 then
                targetTerp.turnRight()
                targetTerp.turnRight()
            end
        elseif (x > 0) then
            if facing[3] > 0 then
                targetTerp.turnRight()
            elseif facing[3] < 0 then
                targetTerp.turnLeft()
            elseif facing[1] > 0 then
                targetTerp.turnRight()
                targetTerp.turnRight()
            end
        elseif (x < 0) then
            if facing[3] == 1 then
                targetTerp.turnLeft()
            elseif facing[3] == -1 then
                targetTerp.turnRight()
            elseif facing[1] < 0 then
                targetTerp.turnRight()
                targetTerp.turnRight()
            end
        end
    end

    function targetTerp.moveTo(x, y, z)
        local start = _location.getLocation()

        dX = x - start.x
        dY = y - start.y
        dZ = z - start.z

        if dZ ~= 0 then
            turnTo(0, dZ)
            terpTarget.forward(math.abs(dZ))
        end
        if dX ~= 0 then
            turnTo(dX, 0)
            terpTarget.forward(math.abs(dX))
        end
        if dY > 0 then
            terpTarget.up(dY)
        elseif dY < 0 then
            terpTarget.down(math.abs(dY))
        end
    end

    return _location
end

--endregion

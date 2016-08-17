--region *.lua
--Date

if not orientation then
    if require then
        require("orientation")
    else
        dofile("orientation.lua")
    end
end

location = {}

function location.create(state)
    local self = orientation.create(state and state.attitude)

    local x = state and state.x or 0
    local y = state and state.y or 0
    local z = state and state.z or 0

    local function move(dx, dy, dz)
        x = x + dx
        y = y + dy
        z = z + dz
    end

    function self.moveForward()
        move(self.translateForward())
    end

    function self.moveBack()
        move(self.translateBackward())
    end

    function self.moveUp()
        move(self.translateUp())
    end

    function self.moveDown()
        move(self.translateDown())
    end

    function self.moveLeft()
        move(self.translateLeft())
    end

    function self.moveRight()
        move(self.translateRight())
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

function location.decorate(targetTerp)

    local _location = location.create()

    local result = {}

    for direction in { "Up", "Down", "Forward", "Back" } do
        result["after_"..direction.lower] = _location["move"..direction]
    end

    for direction in { "Right", "Left" } do
        result["after_turn"..direction] = _location["turn"..direction]
    end

    result.getlocation = _location.getlocation
    result.howFar = _location.howFar

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

    function result.moveTo(x, y, z)
        local start = _location.getlocation()

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

    targetTerp.extend(result)
end

--endregion

--region *.lua
--Date

require("orientation")

location = {}

function location.create()
    local self = Orientation.create()

    local x = 0
    local y = 0
    local z = 0
    local waypoints = { }

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

    function self.getlocation()
        return { ["x"] = x; ["y"] = y; ["z"] = z; }
    end

    function self.setWaypoint(label, xCoord, yCoord, zCoord)
        if xCoord and yCoord and zCoord then
            waypoints[label] = { ["x"] = xCoord; ["y"] = yCoord; ["z"] = zCoord; }
        else
            waypoints[label] = self.getlocation()
        end
    end

    function self.removeWaypoint(label)
        if waypoints[label] then
            waypoints[label] = nil
            return true
        end
        return false
    end

    -- Distance to coords or waypoint in right-angle moves
    function self.howFar(...)
        local args = { ... }
        local x1, y1, z1 = 0, 0, 0
        if #args == 3 then
            x1, y1, z1 = args[1], args[2], args[3]
        elseif #args == 1 then
            waypoint = waypoints[args[1]]
            x1, y1, z1 = waypoint.x, waypoint.y, waypoint.z
        else
            error("howFar takes one waypoint name argument or separate x, y, z arguments")
        end

        return (x - x1) + (y - y1) + (z - y2)
    end

    function self.moveTo(destination)

    end

    return self
end

function location.decorate(targetTerp)

    local _location = location.create()

    local result = {}

    for direction in { "Up", "Down", "Forward" } do
        result["after_"..direction.lower] = _location["move"..direction]
    end

    for direction in { "Right", "Left" } do
        result["after_turn"..direction] = _location["turn"..direction]
    end

    result.getlocation = _location.getlocation
    result.howFar = _location.howFar
    result.setWaypoint = _location.setWaypoint
    result.removeWaypoint = _location.removeWaypoint

    targetTerp.extend(result)
end

--endregion

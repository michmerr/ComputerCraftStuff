--region *.lua
--Date

waypoint = { }
waypoints = { }

-- Checks the equality of the waypoints' locations. Ignores label and connections
function waypoint.equal(a, b)
    if not a and not b then
        return true
    end
    if not a or not b then
        return false
    end

    return a.x == b.x and a.y == b.y and a.z == b.z
end

function waypoint.create(label, x, y, z)

    local self = {
         ["label"] = label;
         ["x"] = x;
         ["y"] = y;
         ["z"] = z;
         }

    self equals(...)
        local args = { ... }
        if #args == 1 and type(args[1] == "table") then
            return waypoint.equal(self, args[1])
        elseif #args == 3 then
            return self.x == args[1] and self.y == args[2] and self.z == args[3]
        else
            error("Expected either a waypoint table or x, y, z coordinates")
        end
    end

    return self
end


function waypoints.create( ... )
    local self = { }

    local items = { ... }

    local function get(index)
        if type(index) == "string" then
            for i = 0, #items do
                if items[i].label == index then
                    return items[i]
                end
            end
        else
            return items[index]
        end
    end

    -- Walks back up the list of waypoints to the target waypoint, removing any side-trips
    function findRoute(to)
        local result = { }
        for i = #items, 1, -1 do
            for j = i - 1, 1, -1 do
                if items[j].equals(to) then
                    break
                end
                if items[i].equals(items[j]) then
                    i = j
                end
            end
            table.insert(result, items[i])
        end

        return result
    end

    function self.howFar(x, y, z, waypoint)
        local w = items[#items]
        local result = math.abs(x - w.x) + math.abs(y - w.y) + math.abs(z - w.z)
        if w.equals(waypoint) then
            return result
        end

        local route = findRoute(waypoint)
        -- Add the combined distances between waypoints to the distance to the most recent waypoint
        for i = 2, #routes do
            local t = routes[i]
            local f = routes[i - 1]
            result = result + math.abs(t.x - f.x) + math.abs(t.y - f.y) + math.abs(t.z - f.z)
        end

        return result
    end

    function self.add(waypoint)
        table.insert(items, waypoint)
    end

    function self.remove(index)
        table.remove(items, index)
    end

    function self.clear()
        items = { }
    end

    return self
end

function waypoints.decorate(terpInstance)

    local _waypoints = waypoints.create()
    local _howFar = terpInstance.howFar

    local self = { }

    function self.setWaypoint(label, xCoord, yCoord, zCoord)
        local result
        if xCoord and yCoord and zCoord then
            result = waypoint.create(label, xCoord, yCoord, zCoord)
        else
            local currentLocation = terpInstance.getlocation()
            result = waypoint.create(label, currentLocation.x, currentLocation.y, currentLocation.z)
        end
        _waypoints.add(result)
        return result
    end

    function self.removeWaypoint(label)
        _waypoints.remove(label)
    end

    function self.howFar(...)
        local args = { ... }
        if #args == 1 then
            waypoint = args[1]
            if type(waypoint) == "table" then
                return _waypoints.howFar(waypoint)
            else
                return _waypoints.howFar(_waypoints.get(waypoint))
            end
        elseif #args == 3 then
            return _howFar(args[1], args[2], args[3])
        else
            error("howFar takes one waypoint name argument or separate x, y, z arguments")
        end
    end

    function self.followWaypointsTo(to)
        local route = _waypoints.findRoute(to)
        for i = 1, #route do
            if not terpInstance.moveTo(route[i].x, route[i].y, route[i].z)
                return false
            end
            _waypoints.add(route[i])
        end
        return true
    end

    terpInstance.extend(self)

end


--endregion

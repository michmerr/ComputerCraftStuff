-- region *.lua
-- Date

--
-- The intent is to allow a series of waypoints to be defined for sequential movement. This allows
-- for specific routing, whether to a destination or retracing a path. In many cases this is overkill,
-- but in cases where a series of different actions has been performed, placing a lot of solid objects
-- between the current and target position, it can prevent slower, destructive transit through that space.

if not terp then
  os.loadAPI("/terp/lib/terp")
end

if not location then
  os.loadAPI("/terp/lib/location")
end

if not waypoint then
  os.loadAPI("/terp/lib/waypoint")
end

function create(...)
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
  function self.findRoute(to)
    local toIndex
    for i = #items, 1, -1 do
      if items[i].equals(to) then
        toIndex = i
        break
      end
    end
    -- destination is not back along the logged waypoints,
    -- take a direct route.
    if not toIndex then
      return { to }
    end
    
    local result = { }
    for i = #items, toIndex + 1, -1 do
      -- bypass any loops
      for j = i - 1, toIndex + 2, -1 do
        if items[i].equals(items[j]) then
          i = j
        end
      end
      table.insert(result, items[i])
    end

    return result
  end

  function self.howFar(x, y, z, wp)
    local route = findRoute(wp)

    -- first, distance from current position to the first waypoint on the route
    local w = route[1]
    local result = w:howFar(x, y, z)

    -- Add the combined distances between waypoints on the route
    for i = 1, #route - 1 do
      result = result + route[i]:howFar(route[i + 1])
    end

    return result
  end

  function self.add(wp)
    table.insert(items, wp)
  end

  function self.remove(index)
    table.remove(items, index)
  end

  function self.clear()
    items = { }
  end

  function self.count()
    return #items
  end

  return self
end


local _waypoints = create()
local _howFar = terp.howFar
local _moveTo = terp.moveTo

function terp.setWaypoint(label, xCoord, yCoord, zCoord)
  local result
  if xCoord and yCoord and zCoord then
    result = waypoint.new(label, xCoord, yCoord, zCoord)
  else
    local currentLocation = terp.getlocation()
    result = waypoint.new(label, currentLocation.x, currentLocation.y, currentLocation.z)
  end
  _waypoints.add(result)
  return result
end

function terp.getLastWaypoint()
  return _waypoints.get(_waypoints.count())
end

function terp.removeWaypoint(label)
  _waypoints.remove(label)
end

function terp.howFar(...)
  local args = { ... }
  local start = terp.getLocation()
  local wp
  if #args == 1 then
    wp = args[1]
    if type(wp) == "table" then
      return _waypoints.howFar(start.x, start.y, start.z, wp)
    else
      return _waypoints.howFar(start.x, start.y, start.z, _waypoints.get(wp))
    end
  elseif #args == 3 then
    return _howFar(args[1], args[2], args[3])
  else
    error("howFar takes one waypoint name argument or separate x, y, z arguments")
  end
end

function terp.moveTo(...)
  local args = { ... }
  if #args == 3 then
    return _moveTo(...)
  end
  assert(#args == 1, "Expecting x, y, z or a waypoint")
  local route = _waypoints.findRoute(args[1])
  for i = 1, #route do
    if not _moveTo(route[i]) then
      return false
    end
    _waypoints.add(route[i])
  end
    
  return true
end




-- endregion

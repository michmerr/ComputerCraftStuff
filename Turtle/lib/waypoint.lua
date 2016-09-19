-- region *.lua
-- Date

local waypointBase = { }
local mt = { __index = waypointBase }

function new(label, x, y, z)

  local self = {
    ["label"] = label;
    ["x"] = x or 0;
    ["y"] = y or 0;
    ["z"] = z or 0;
  }

  return setmetatable(self, mt)
end

function waypointBase:howFar(...)
  local args = { ... }
  assert(#args == 1 or #args == 3, "How far to where?")
  local x, y, z
  if (#args == 1) then
    x = args[1].x
    y = args[1].y
    z = args[1].z
  else
    x = args[1]
    y = args[2]
    z = args[3]
  end
  local dx = self.x - x
  local dy = self.y - y
  local dz = self.z - z
  local distance = math.abs(dx) + math.abs(dy) + math.abs(dz)

  return distance, dx, dy, dz
end

-- Checks the equality of the waypoints' locations. Ignores label and connections
function waypointBase:equals(w)
  if not w then
    return false
  end

  return self.x == w.x and self.y == w.y and self.z == w.z
end

mt.__eq = waypointBase.equals

-- endregion

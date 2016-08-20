--region *.lua
--Date

local waypointBase = { }
local mt = { __index = waypointBase }

function new(label, x, y, z)

    local self = {
         ["label"] = label;
         ["x"] = x;
         ["y"] = y;
         ["z"] = z;
         }

    return setmetatable(self, mt)
end


-- Checks the equality of the waypoints' locations. Ignores label and connections
function waypointBase:equals(w)
    if not b then
        return false
    end

    return self.x == w.x and self.y == w.y and self.z == w.z
end

mt.__eq = waypointBase.equals

--endregion

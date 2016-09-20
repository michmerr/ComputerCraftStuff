--region *.lua

if not utilities then
    if require then
        require("utilities")
    else
        dofile("/terp/lib/utilities")
    end
end

local recipeBase = { }
local mt = { __index = recipeBase }

function new(o)
    local self = o or { }
    return setmetatable(self, mt)
end


--endregion

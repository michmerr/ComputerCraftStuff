--region *.lua

require("utilities")
require("terp")
if not turtle then
    require("turtle")
end

inventory = {}

function inventory.create(keepItems, dropPoint)
    local self = { }


end

function inventory.decorate(terpInstance, keepItems, dropPoint)

    local instance = inventory.create(keepItems, dropPoint)

    local extension = { }

    function extension.triggerDrop()
        return instance.triggerDrop(terpInstance)
    end

    function extension.checkFull()
        return _refuel.checkFull(terpInstance)
    end

    function extension.waitForRefueling(returnToWaypoint)
        return _refuel.waitForRefueling(terpInstance, returnToWaypoint)
    end

    for direction in { "Up", "Down", "Forward" } do
        extension["after_"..direction.lower] = triggerRefuel
    end

    turtleInstance.extend(extension)
end

--endregion

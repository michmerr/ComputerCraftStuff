--region *.lua

require("utilities")
require("terp")
if not turtle then
    require("turtle")
end

inventory = {}

function inventory.create(keepFuel)
    local self = { }


end

function inventory.decorate(terpInstance, minFuelForOperation, optimumTopOff, minFuelAfterReturn, fuelPoint)

    local _refuel = Refuel.create(minFuelForOperation, optimumTopOff, minFuelAfterReturn, fuelPoint)

    local extension = { }

    function triggerRefuel()
        return _refuel.triggerRefuel(terpInstance)
    end

    function extension.checkFull()
        return _refuel.checkBingo(terpInstance, safetyMargin, waypoint)
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

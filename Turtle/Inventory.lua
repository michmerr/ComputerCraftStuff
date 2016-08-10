--region *.lua

require("location")
require("terp")
if not turtle then
    require("turtle")
end

TurtleRefuel = {}

function inventory.create(keepFuel)



    local self = { }

    -- copy of os.sleep, but with check for the event we're expecting
    -- returns success, eventParam1, eventParamN, ...
    function waitForEvent(filter, timeout)
        local timer, event, param, notification
        if (timeout and timeout > 0) then
            timer = os.startTimer( timeout )
        end

        repeat
            notification = { os.pullEvent() }
            event, param = table.unpack(notification)
        until param == timer or event == filter or not filter

        if (param ~= timer) then
            return table.unpack(notification)
        end

        return false
    end

end

function inventory.decorate(terpInstance, minFuelForOperation, optimumTopOff, minFuelAfterReturn, fuelPoint)

    local _refuel = Refuel.create(minFuelForOperation, optimumTopOff, minFuelAfterReturn, fuelPoint)

    local extension = { }

    function triggerRefuel()
        return _refuel.triggerRefuel(terpInstance)
    end

    function extension.checkBingo(safetyMargin, waypoint)
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

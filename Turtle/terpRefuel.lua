--region *.lua

require("location")
require("terp")
require("utilities")
if not turtle then
    require("turtle")
end

terpRefuel = {}

function terpRefuel.create(useInventory, minFuelForOperation, optimumTopOff, minFuelAfterReturn, fuelPoint)

    local waitForFuelLevel = minFuelForOperation or 500
    local takeFuelUntilLevel = optimumTopOff
    local fuelPointLocation = fuelPoint or { ["x"] = 0; ["y"] = 0; ["z"] = 0 }
    local refueling = false
    local fuelSafetyMargin = minFuelAfterReturn or 0

    local self = { }

    function self.refuelFromInventory(terpInstance, takeUntil)
        local takeAmount = takeUntil - terpInstance.getFuelLevel()
        for slot = 1, 16 do
            if takeAmount <= 0 then
                break
            end
            terpInstance.select(slot)
            terpInstance.refuel(takeAmount)
            takeAmount = takeUntil - terpInstance.getFuelLevel()
        end
    end

    function self.waitForRefueling(terpInstance)
        -- operational minimum, plus fuel to get there and back
        local minFuel = waitForFuelLevel
        if returnToWaypoint then
            minFuel = minFuel + terpInstance.howFar(returnToWaypoint)
        end

        if minFuel > terpInstance.getFuelLimit() then
            minFuel = terpInstance.getFuelimit()
        end

        if takeFuelUntilLevel > terpInstance.getFuelLimit() then
            takeFuelUntilLevel = terpInstance.getFuelLimit()
        end

        local fuelLevel

        -- optimistically planning on getting the optimum fuel level
        while terpInstance.getFuelLevel() < takeFuelUntilLevel do
            fuelLevel = terpInstance.getFuelLevel()
            -- wait for manual refuel
            if (utilities.waitForEvent("turtle_inventory", 5)) then
                refuelFromInventory(terpInstance, takeFuelUntilLevel)
            end
            os.sleep(3)
            -- Wait for the inventory events and fuel level changes to stop, to allow
            -- for manual addition of multiple fuel items and/or a charging station to
            -- continue charging. The inventory check

            if terpInstance.getFuelLevel() > minFuel and terpInstance.getFuelLevel() == fuelLevel then
                break
            end
        end
    end

    -- returns fuel temaining before return to the waypoint would be required
    function self.checkBingo(terpInstance, safetyMargin, waypoint)
        if not safetyMargin then
            safetyMargin = fuelSafetyMargin
        end

        if not waypoint then
            waypoint = fuelPointLocation
        end

        local distance = terpInstance.howFar(waypoint)
        local bingoFuel = distance + safetyMargin
        return terpInstance.getFuelLevel() - bingoFuel
    end

    function self.triggerRefuel(terpInstance)
        if refueling then
            return true
        end
        local bingo = self.checkBingo()
        if not bingo or bingo > 0 then
            return true
        end
        if useInventory then
            if takeFuelUntilLevel > terpInstance.getFuelLimit() then
                takeFuelUntilLevel = terpInstance.getFuelLimit()
            end
            refuelFromInventory(terpInstance,  takeFuelUntilLevel)
            if not bingo or bingo > 0 then
              return true
            end
        end
        refueling = true
        local returnTo
        if terpInstance.followWaypointsTo then
            returnTo = terpInstance.setWaypoint("resumeWork")
            if not terpInstance.followWaypointsTo(fuelPointLocation) then
                return false
            end
        else
            returnTo = terpInstance.getLocation()
            if not terpInstance.moveTo(fuelPointLocation) then
                return false
            end
        end
        if not self.waitForRefueling(terpInstance) then
            return false
        end
        if terpInstance.followWaypointsTo then
            if not terpInstance.followWaypointTo(returnTo) then
                return false
            end
            terpInstance.removeWaypoint(returnTo)
        else
            if not terpInstance.moveTo(returnTo.x, returnTo.y, returnTo.z) then
                return false
            end
        end

        refueling = false

        return true
    end

    return self
end

function terpRefuel.decorate(terpInstance, minFuelForOperation, optimumTopOff, minFuelAfterReturn, fuelPoint)

    local _refuel = Refuel.create(minFuelForOperation, optimumTopOff, minFuelAfterReturn, fuelPoint)

    local extension = { }

    function extension.triggerRefuel()
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

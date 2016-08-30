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

    function selectMaterialSlot(lower, upper, types)
      if turtle.getSelectedSlot() >= lower and turtle.getSelectedSlot() <= upper and turtle.getItemCount() > 0 then
          return true
      end
  --TODO: check against list of acceptable item types

      for i = lower, upper do
          if turtle.getItemCount(i) > 0 then
              turtle.select(i)
              return true
          end
      end

      return false
    end

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

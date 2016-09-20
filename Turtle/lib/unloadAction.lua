--region *.lua

if not terp then
  os.loadAPI("/terp/lib/terp")
end

if not inventory then
  os.loadAPI("/terp/lib/inventory")
end

local defaultContainerItemTypes = inventory.allItems:where(
  function(item)
    return item.inventory
  end)

-- potential issues if something is loaded after this that overrides terp
-- functions, so use string for runtime indexing.
directions = {
  up = { inspect = "inspectUp"; drop = "dropUp"; };
  down = { inpect = "inspectDown"; drop = "dropDown" };
  forward = { inspect = "inspect"; drop = "drop"; }
  }
  
function getValidator(validTargets)
  validTargets = validTargets or defaultContainerItemTypes
  local result
  local targetTypes, targetValid
  if type(validTargets) == "string" then
    result = function(details)
        return details.name..":"..details.damage == validTargets
      end
  elseif type(validTargets) == "function" then
    result = validTargets
  elseif type(validTargets) == "table" then
    result = function(details)
        return validTargets:contains(details)
      end
  else
    return nil, "Expected a string, list, or function to validate unload target."
  end

  return result
end

function create(validTargets, direction, slotRangeLow, slotRangeHigh)

  local targetValid = assert(getValidator(validTargets))
  direction = direction or directions.forward
  slotRangeLow = slotRangeLow or 1
  slotRangeHigh = slotRangeHigh or 16

  local self = {}

  function self.run()
    local firstAttempt = true
    while not targetValid(terp[direction.inspect]()) do
      if firstAttempt then
        print("Valid unload target not present. Waiting for acceptable unload conditions...")
        firstAttempt = false
      end
      os.sleep(5)
    end
    for i = slotRangeLow, slotRangeHigh do
      terp.select(i)
      firstAttempt = true
      while not terp[direction.drop]() do
        if firstAttempt then
          print("Unload failed, possibly due to a full container. Retrying until successful...")
          firstAttempt = false
        end
        os.sleep(5)
      end
    end
    return true
  end

end



--endregion

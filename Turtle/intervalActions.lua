--region *.lua
--Date

function placeTorches(horizontalInterval, verticalInterval, height, materialSlotRangeLow, materialSlotRangeHigh)

  local action = { }

  action.horizontal = horizontalInterval
  action.verticalInterval = verticalInterval
  action.height = height
  action.materialSlotRangeLow = materialSlotRangeLow
  action.materialSlotRangeHigh = materialSlotRangeHigh
  -- action.materialTypes = { }

  function action.check(job)
    if not job.isOnWall() then
      return
    end

    if job.above and action.height == 1 then
      return
    end

    local vMatch = action.verticalInterval and action.verticalInterval % job.distance.vertical == 0
    local hMatch = action.horizontalInterval and action.horizontalInterval % job.distance.vertical == 0

    if not vMatch and not hMatch then
      return
    end

    local originalFacing = turtle.getFacing()
    local rY
    turtle.turnTo(job.towardsWall)
    if above then
      if action.height == 2 then
        turtle.down()
        rY = turtle.Up()
      elseif action.height == 3 then
        turtle.up()
        rY = turtle.Down()
      end
    end

    placeForward(job.materialSlotRangeLow, job.materialSlotRangeHigh, job.materialTypes)
    local result = placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes)

    if rY then
      rY()
    end

    turtle.turnTo(originalFacing)

    return result
  end

  return action
end

function placeRailings(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)

  local action = { }

  action.materialSlotRangeLow = materialSlotRangeLow
  action.materialSlotRangeHigh = materialSlotRangeHigh
  action.materialTypes = materialTypes

  function action.check(job)
    if job.above or job.isOnWall() then
      return true
    end

    local originalFacing = turtle.getFacing()
    turtle.turnTo(job.towardsEdge)
    local result = true
    if not turtle.detect() then
      turtle.forward()
      placeDown(job.materialSlotRangeLow, job.materialSlotRangeHigh, job.materialTypes)
      turtle.back()
      result = placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes)
    end

    turtle.turnTo(originalFacing)
    return result
  end

  return action
end

function seal(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)

  local action = { }

  action.materialSlotRangeLow = materialSlotRangeLow
  action.materialSlotRangeHigh = materialSlotRangeHigh
  action.materialTypes = materialType

  function action.check(job)
    local result = true
    local originalFacing = turtle.getFacing()
    if job.isOnWall() then
      turtle.turnTo(job.towardsWall)
    else
      turtle.turnTo(job.towardsEdge)
    end

    if job.above then
      turtle.down()
      if not turtle.detect() and not placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) then
        turtle.down()
        if not placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) then
          turtle.forward()
          if not turtle.placeDown(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) then
            local loc = turtle.getLocation()
            print(string.format("error sealing stairwell at %d, %d, %d (relative)", loc.x, loc.y, loc.z))
          end
          turtle.back()
          result = placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) and result
        end
        turtle.up()
        result = placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) and result
      end
      turtle.up()
      result = turtle.detect() or placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) and result
      turtle.up()
      result = turtle.detect() or placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) and result
      if not turtle.detectUp() and not placeUp(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) then
        turtle.up()
        placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes)
        turtle.down()
        placeUp(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes)
      end
      local halfWay = math.ceil(job.treadWidth / 2)
      for i = 2, halfWay do
        turtle.back()
        placeUp(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes)
      end
      for i = 2, halfWay do
        turtle.forward()
      end
      turtle.down()
    else
      if not turtle.detect() and not placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) then
        turtle.forward()
        if not turtle.placeDown(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) then
          local loc = turtle.getLocation()
          print(string.format("error sealing stairwell at %d, %d, %d (relative)", loc.x, loc.y, loc.z))
        end
        turtle.back()
        result = placeForward(action.materialSlotRangeLow, action.materialSlotRangeHigh, action.materialTypes) and result
      end
    end
    turtle.turnTo(originalFacing)
    return result
  end

  return action
end



--endregion

--region *.lua
--Date

function placeOnStairsWallAction(horizontalInterval, verticalInterval, height, meterialTypes, materialSlotRangeLow, materialSlotRangeHigh)

  local action = { }

  action.horizontalInterval = horizontalInterval
  action.verticalInterval = verticalInterval
  action.height = height
  action.materialSlotRangeLow = materialSlotRangeLow
  action.materialSlotRangeHigh = materialSlotRangeHigh
  action.materialTypes = { }
  action.verticalsDone = 0

  function action.shouldRun(job)
    local logger = job.getLogger()
    logger:log(Logger.levels.DEBUG, "placeOnStairsWallAction.shouldRun()")

    -- since and item placed on the wall will potentially block the turtle, we will place at position - 1.
    -- this avoids the complexities of figuring out where in the traverse passes something can get placed without
    -- running into it in the next pass.

    local vMatch = action.verticalInterval and job.getVerticalDistance() % action.verticalInterval  == 0 and action.verticalsDone < job.getVerticalDistance() / action.verticalInterval
    local hMatch = action.horizontalInterval and job.getWallDistance() % action.horizontalInterval  == 1 and job.getWallDistance() > 1
    logger:log(Logger.levels.DEBUG, "  verticalInterval = %s", tostring(action.verticalInterval))
    logger:log(Logger.levels.DEBUG, "  horizontalInterval = %s", tostring(action.horizontalInterval))
    logger:log(Logger.levels.DEBUG, "  getVerticalDistance = %s", tostring(job.getVerticalDistance()))
    logger:log(Logger.levels.DEBUG, "  getWallDistance = %s", tostring(job.getWallDistance()))
    logger:log(Logger.levels.DEBUG, "  vMatch = %s", tostring(vMatch))
    logger:log(Logger.levels.DEBUG, "  hMatch = %s", tostring(hMatch))

    if not vMatch and not hMatch then
      logger:log(Logger.levels.DEBUG, "no interval match.")
      return false
    end

    if not job.isOnWall() then
      logger:log(Logger.levels.DEBUG, "not on wall.")
      return false
    end

    if job.getPassageWidth() < 2 then
      logger:log(Logger.levels.ERROR, "Can't place items on wall when width is less than two.")
      logger:log(Logger.levels.DEBUG, "returning from placeOnStairsWallAction.check()")
      return false, "Can't place items on wall when width is less than two."
    end

    -- only go on the high/low pass that requires the least vertical movement
    if (job.atFloorLevel() and not job.goingUp()) or (not job.atFloorLevel() and job.goingUp()) then
      return false
    end

    if vMatch then
      action.verticalsDone = action.verticalsDone + 1
    end

    return true
  end

  function action.check(job, corner)
    local logger = job.getLogger()
    if not action.shouldRun(job) or corner then
      return false
    end

    local result = false

    local originalFacing = terp.getFacing()
    terp.turnTo(job.getLastDirection())
    terp.forward()
    local dY = action.height - 2
    if not job.isNextToPreviousStep() then
      dY = dY + job.goingUp() and 1 or -1
    end
    if dY > 0 then
      for i = 1, dY do
        terp.up()
      end
    elseif dY < 0 then
      for i = 1, dY do
        terp.down()
      end
    end
    terp.turnTo(job.getWallDirection())

    -- place wall piece, if necessary
    if not terp.detect() then
      terp.placeItem(job.getMaterialTypes(), job.getMaterialSlotRangeLow(), job.getMaterialSlotRangeHigh())
    end

    -- back off to provide room for placement
    terp.back()
    result = terp.placeItem(action.materialTypes, action.materialSlotRangeLow, action.materialSlotRangeHigh)

    -- return to starting height
    if dY > 0 then
      for i = 1, dY do
        terp.down()
      end
    elseif dY < 0 then
      for i = 1, dY do
        terp.up()
      end
    end

    -- move back to starting step
    terp.turnTo(job.getNextDirection())
    terp.forward()
    terp.turnTo(job.getWallDirection())
    -- go forward to balance the back() for placement
    terp.forward()
    terp.turnTo(originalFacing)

    logger:log(Logger.levels.DEBUG, "returning from placeOnStairsWallAction.check()")
    return result
  end

  return action
end

function placeRailingsOnStairsAction(materialTypes, materialSlotRangeLow, materialSlotRangeHigh)

  local action = { }

  action.materialSlotRangeLow = materialSlotRangeLow
  action.materialSlotRangeHigh = materialSlotRangeHigh
  action.materialTypes = materialTypes

  function action.check(job)

    if job.getPassageWidth() < 2 then
      job.getLogger():log(Logger.levels.ERROR, "Can't place items when width is less than two.")
      return false, "Can't place items when width is less than two."
    end

    -- since a placed item will not allow the turtle to move back into that position,
    -- the operation will actually be performed on the previous stair step.
    if not job.isOnEdge() then
      return false
    end

    local jobUp = job.getHeight > 0
    local jobAbove = not job.atFloorLevel()

    -- wait for the cycle where the turtle is most aligned with the previous step height
    if (jobUp and jobAbove) or (not jobUp and not jobAbove) then
      return false
    end

    local originalFacing = terp.getFacing()
    terp.turnTo(job.getDirectionLast())
    local result = false
    terp.forward()
    result = terp.placeItemDown(action.materialTypes, action.materialSlotRangeLow, action.materialSlotRangeHigh)
    terp.back()
    terp.turnTo(originalFacing)
    return result
  end

  return action
end

function seal(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)

  local action = { }

  action.materialSlotRangeLow = materialSlotRangeLow
  action.materialSlotRangeHigh = materialSlotRangeHigh
  action.materialTypes = materialType

  local function tryPlace(place, r, e)
    local result = r
    if not terp.detect() and not terp.placeItem(action.materialTypes, action.materialSlotRangeLow, action.materialSlotRangeHigh) then
      local loc = terp.getLocation()
      local err = string.format("error sealing stairwell at %d, %d, %d (relative)", loc.x, loc.y, loc.z)
      return false, e and e..";"..err or err
    end
    return result, e
  end

  function action.check(job)
    local result = true
    local err
    local originalFacing = terp.getFacing()
    if job.isOnWall() then
      terp.turnTo(job.getWallDirection())
    else
      terp.turnTo(job.getEdgeDirection())
    end

    result, err = tryPlace(terp.placeItem, true)
    if not job.atFloorLevel() then
      terp.down()
      result, err = tryPlace(terp.placeItem, result, err)
      terp.up()
      terp.up()
      result, err = tryPlace(terp.placeItem, result, err)
      result, err = tryPlace(terp.placeItemUp, result, err)
      terp.down()
    end
    terp.turnTo(originalFacing)
    return result, err
  end

  return action
end



--endregion

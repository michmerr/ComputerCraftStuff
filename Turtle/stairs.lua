-- region *.lua
-- Date
if not utilities then
  dofile("/terp/utilities")
end

if not terp then
  os.loadAPI("/terp/terp")
end

if not location then
  os.loadAPI("/terp/location")
end

if not inventory then
  os.loadAPI("/terp/inventory")
end

if not FileLogger then
  os.loadAPI("/terp/FileLogger")
end
if not ConsoleLogger then
  os.loadAPI("/terp/ConsoleLogger")
end

local defaultStairItemTypes = inventory.allItems:where(
  function(item)
    return (item.structural and not item.fill)
  end)


function new()
-- treadWidth, treadDepth, height, maxLength, maxWidth, measureOutside, clockwise, materialSlotRangeLow, materialSlotRangeHigh, materialTypes, intervalActions)
  local treadWidth = 1;
  local treadDepth = 1;
  local outside = true;
  local clockwise = true;
  local materialSlotRangeLow = 1;
  local materialSlotRangeHigh = 16;
  local materialTypes = defaultStairItemTypes;
  local intervalActions = { };
  local count = 0;
  local distance = { wall = 0; edge = 0 };
  local height = 0;
  local length = -1;
  local width = -1;
  local wallSide = orientation.transforms.yawLeft;
  local edgeSide = orientation.transforms.yawRight;
  local above = false  -- state of alternating high/low paths. stair tread level is false, two spaces up is true
  local towardsNext = { }
  local towardsWall = { }
  local towardsEdge = { }
  local towardsLast = { }
  local startingPoint = { }

  local self = { }

  local function log(...)
    self.getLogger():log(...)
  end

  local function updateSides()
    if (outside and clockwise) or (not outside and not clockwise) then
      wallSide = orientation.transforms.yawLeft
      edgeSide = orientation.transforms.yawRight
    else
      wallSide = orientation.transforms.yawRight
      edgeSide = orientation.transforms.yawLeft
    end
  end

  self.id = tostring(os.time() * 1000)

  function self.getTreadWidth()
    return treadWidth
  end

  function self.setTreadWidth(value)
    assert(value and type(value) == "number" and value > 0, "value must be a positive number (value passed was "..tostring(value)..")")
    treadWidth = value
  end

  function self.getTreadDepth()
    return treadDepth
  end

  function self.setTreadDepth(value)
    assert(value and type(value) == "number" and value > 0, "value must be a positive number (value passed was "..tostring(value)..")")
    treadDepth = value
  end

  function self.getTurnOutside()
    return outside
  end

  function self.setTurnOutside(value)
    assert(value and type(value) == "boolean", "value must be a boolean (value passed was "..tostring(value)..")")
    outside = value
    updateSides()
  end

  function self.getClockwise()
    return clockwise
  end

  function self.setClockwise(value)
    assert(value and type(value) == "boolean", "value must be a boolean (value passed was "..tostring(value)..")")
    clockwise = value
    updateSides()
  end

  function self.getMaterialSlotRangeLow()
    return materialSlotRangeLow
  end

  function self.getMaterialSlotRangeHigh()
    return materialSlotRangeHigh
  end

  function self.setMaterialSlotRange(low, high)
    assert(low or type(low) == "number" and low > 0 and low < 17, "value must be a positive number between 1 and 16 (value passed was "..tostring(low)..")")
    assert(high or type(high) == "number" and high >= low and high < 17, "value must be a positive number between "..tostring(low).." and 16 (value passed was "..tostring(high)..")")

    materialSlotRangeLow = low
    materialSlotRangeHigh = high
  end

  function self.getMaterialTypes()
    return materialTypes
  end

  function self.addMaterialType(value)
    materialTypes:add(value)
  end

  function self.removeMaterialType(value)
    materialTypes:remove(value)
  end

  function self.getIntervalActions()
    return intervalActions
  end

  function self.addIntervalAction(value)
    table.insert(intervalActions, value)
  end

  function self.removeIntervalAction(index)
    table.remove(intervalActions, index)
  end

  function self.getCount()
    return count
  end

  function self.resetCount()
    count = 0
  end

  function self.getEdgeDistance()
    return distance.edge
  end

  function self.resetEdgeDistance()
    distance.edge = 0
  end

  function self.getWallDistance()
    return distance.wall
  end

  function self.resetWallDistance()
    distance.wall = 0
  end

  function self.getHeight()
    return height
  end

  function self.setHeight(value)
    assert(value and type(value) == "number" and value ~= 0 and value > -256 and value < 256, "value must be a non-0 number between -255 and 255; value passed was %s", tostring(value))
    height = value
    stairsUp = (value > 0)
  end

  function self.getLength()
    return length > -1 and length or nil
  end

  function self.setLength(value)
    assert(not value or type(value) == "number" and value >= 0, "value must be a non-negative number, or nil to switch back within the defined width (or no limits if width is also undefined). value passed was "..tostring(value))
    length = value or -1
  end

  function self.getWidth()
    return width > -1 and length or nil
  end

  function self.setWidth(value)
    assert(not value or type(value) == "number" and value >= 0, "value must be a non-negative number, or nil to switch back within the defined length (or no limits if length is also undefined). value passed was "..tostring(value))
    width = value or -1
  end

  function self.atTreadLevel()
    return not above
  end

  local dimensionsEvaluated
  -- Evaluate dimensions to adjust values based on defaults, allowing space
  -- for turns, etc.
  local function evaluateDimensions()
    assert(not dimensionsEvaluated, "evaluateDimensions should not be called more than once!")
    dimensionsEvaluated = true

    -- No length or width, just straight stairs
    if length == -1 and width == -1 then
      length = treadDepth * math.abs(height)
      width = treadWidth
    -- If on or the other other is defined, then the undefined values indicates a switchback
    elseif length == -1 then
      length = outside and treadWidth * 2 or 0
    elseif width == -1 then
      length = outside and treadWidth * 2 or 0
    end

    -- if measuring the outside of turns, adjust lengths to allow for landings
    if outside then
      length = length - (2 * treadWidth)
      width = width - (2 * treadWidth)
      assert(length >= 0, "Defined length is insufficient to allow turns with the defined tread width.")
      assert(width >= 0, "Defined width is insufficient to allow turns with the defined tread width.")
    end
  end

  local function setDirections()
    log(Logger.levels.DEBUG, "setDirections")
    towardsNext = terp.getFacing()
    log(Logger.levels.DEBUG, "towardsNext = %s", tostring(towardsNext))
    towardsWall = orientation.getRelative(towardsNext, wallSide)
    log(Logger.levels.DEBUG, "towardsWall = %s", tostring(towardsWall))
    towardsEdge = orientation.getRelative(towardsNext, edgeSide)
    log(Logger.levels.DEBUG, "towardsEdge = %s", tostring(towardsEdge))
    towardsLast = orientation.getRelative(towardsNext, orientation.transforms.reverseYaw)
    log(Logger.levels.DEBUG, "towardsLast = %s", tostring(towardsLast))
  end

  local function changeLateralDirection()
    lateralDirection = lateralDirection == towardsEdge and towardsWall or towardsEdge
    log(Logger.levels.DEBUG, "lateralDirection changed to %s", tostring(lateralDirection))
    return lateralDirection
  end

  local logs
  function self.setLogger(logger)
    logs = logger
  end

  function self.getLogger()
    if not logs then
      logs = Logger.new()
      table.insert(logs.listeners, ConsoleLogger.new())
      table.insert(logs.listeners, FileLogger.new(self.id..".log", Logger.levels.DEBUG))
      Logger.setGlobalLogger(logs)
    end
    return logs
  end

  local function initialize()
    evaluateDimensions()
    setDirections()
    -- start out oriented at the top step on the anchor wall side, so first turn will be toward the edge.
    lateralDirection = towardsEdge
    startingPoint = location.create(terp.getLocation())
  end

  local function move(moveFunc)
    local success, err = moveFunc()
    if not success then
      log(Logger.levels.ERROR, err)
      assert(success, err)
    end
    return true
  end

  local function runIntervalActions()
    if intervalActions then
      for _, action in pairs(intervalActions) do
        action.check(self)
      end
    end
  end

  local function layTread()
    -- this *should* only fail for some sort of logistical reason, since a turtle can place using itself as an anchor.
    local success, err = terp.placeItemDown(materialTypes, materialSlotRangeLow, materialSlotRangeHigh)

    if not success and err then
      local loc = terp.getLocation()
      log(Logger.levels.ERROR, "error placing tread at %d, %d, %d (relative)", loc.x, loc.y, loc.z)
      return false
    end
    return true
  end

  local function clearAirspace()
    terp.digDown()
    terp.digUp()
  end

  local function stepTraversal()
    runIntervalActions()
    if treadWidth > 1 then
      log(Logger.levels.DEBUG, "face down tread: %s", tostring(lateralDirection) )
      terp.turnTo(lateralDirection)
    end

    local action = above and clearAirspace or layTread
    for i = 1, treadWidth do
      if i > 1 then
        log(Logger.levels.DEBUG, "move down tread")
        move(terp.forward)
      end
      action()
    end
    if treadWidth > 1 then
      runIntervalActions()
      changeLateralDirection()
      log(Logger.levels.DEBUG, "turn next: ")
      terp.turnTo(towardsNext)
    end
  end

  local function step(depth, corner)

    log(Logger.levels.DEBUG, "step(depth = %s, corner = %s)", tostring(depth), tostring(corner))
    count = count + 1
    depth = depth or treadDepth

    log(Logger.levels.DEBUG, "step: depth = %s, count = %s)", tostring(depth), tostring(count))
    if stairsUp then
      move(terp.up)
    end

    for i = 1, depth do
      terp.turnTo(towardsNext)
      move(terp.forward)
      if not stairsUp and i == 1 then
        move(terp.down)
      end

      if not corner or outside then
        distance.wall = distance.wall + 1
      elseif not corner or not outside then
        distance.edge = distance.edge + 1
      end

      stepTraversal()

      if above then
        move(terp.down)
        move(terp.down)
      else
        move(terp.up)
        move(terp.up)
      end
      above = not above

      stepTraversal()
    end
  end

  local function flight(length)
    -- Assumes a start position facing the direction to create the flight
    -- of stairs, immediately in front of the first step, and next to the anchor
    -- wall. Initial turn should be away from the anchoring wall. This will be
    -- passed to intervalAction functions so they can orient themselves.

    local stepCount = math.floor(length / treadDepth)
    local remainderDepth = length % treadDepth
    local maxCount = math.abs(height)
    local useDepth = treadDepth
    for i = 1, stepCount do
      if i == stepCount and remainderDepth > 0 then
        -- assume that a landing or other continuation makes a shallow final step ok.
        useDepth = remainderDepth
      end
      step(useDepth)
      if count == maxCount then
        break
      end
    end
  end

  function turnCorner()
    local direction = outside and towardsEdge or towardsWall
    terp.turnTo(direction)
    -- if they're on the outside corner of the turn, move them to the edge of the next step
    if lateralDirection == direction then
      for j = 2, treadWidth do
        move(terp.forward)
      end
    end
    -- update the relative directions to the edge, wall, next step and last step.
    setDirections()

    lateralDirection = outside and towardsEdge or towardsWall

  end

  -- Starting in front of the first step, immediately adjacent to the anchor wall.
  -- Positive height value for stairs up, negative for down.
  -- Table of interval actions that will be called as functions with the step count, current  lateralDirection, above, and initial lateralDirection after each step.
  function self.build()

    initialize()
    local totalCount = math.abs(height)
    log(Logger.levels.INFO, "Starting build of stairs")
    log(Logger.levels.INFO, "Total vertical change: %s", tostring(height))
    log(Logger.levels.INFO, "Steps: %d wide X %d deep", treadWidth, treadDepth)
    log(Logger.levels.INFO, "Footprint: %d X %d (measured on %s of turn)", length, width, outside and "outside" or "inside")
    log(Logger.levels.INFO, "Rotation: %s", clockwise and "clockwise" or "counter-clockwise")
    log(Logger.levels.INFO, "Using materials in slots %d - %d", materialSlotRangeLow and materialSlotRangeLow or 1, materialSlotRangeHigh and materialSlotRangeHigh or 16)

    if outside then
      -- flush landing
      move(terp.up)
      local savedUp = stairsUp
      stairsUp = false
      step(treadWidth)
      stairsUp = savedUp
      count = 0
    end

    local activeLength = length
    while count < totalCount do
      flight(activeLength)
      activeLength = activeLength == length and  width or length
      if count < totalCount then
        step(treadWidth)
        turnCorner()
      end
    end

    if above then
      terp.down()
      terp.down()
    end
  end

  return self
end
-- endregion
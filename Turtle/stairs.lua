-- region *.lua
-- Date

if not terp then
  os.loadAPI("terp")
end

if not location then
  os.loadAPI("location")
end

function createJob(treadWidth, treadDepth, height, maxLength, maxWidth, measureOutside, clockwise, materialSlotRangeLow, materialSlotRangeHigh, materialTypes, intervalActions)
  local job = { }
  job.treadWidth = treadWidth and treadWidth > 0 or 1
  job.treadDepth = treadDepth and treadWidth > 0 or 1
  job.height = assert(height, "Height must be set. To go down to bedrock, just use a large negative number")
  job.outside = measureOutside
  job.clockwise = clockwise
  job.materialSlotRangeLow =(materialSlotRangeLow and materialSlotRangeLow > 0 and materialSlotRangeLow) < 16 or 2
  job.materialSlotRangeHigh =(materialSlotRangeHigh and materialSlotRangeHigh > 0 and materialSlotRangeHigh < 16 and materialSlotRangeHigh <= job.materialSlotRangeLow) or 16
  job.materialTypes = materialTypes
  job.intervalActions = intervalActions
  job.count = 0
  job.stairsUp = height > 0
  job.distance = { wall = 0; edge = 0 }

  job.length = maxLength
  job.width = maxWidth
  -- No length or width, just straight stairs
  if not maxLength and not maxWidth then
    job.length = job.treadDepth * math.abs(height)
    job.width = 0
    -- Length or width, time for a switchback
  elseif not job.length then
    job.length = 0
  elseif not job.width then
    job.width = 0
    -- Spiral, adjust lengths for inside versus outside turns to allow for landings
  elseif job.outside then
    job.length = job.length -(2 * job.treadWidth)
    job.width = job.width -(2 * job.treadWidth)
  end

  job.towardsNext = { }
  job.towardsWall = { }
  job.towardsEdge = { }
  job.towardsLast = { }

  if (outside and clockwise) or (not outside and not clockwise) then
    job.wallSide = orientation.transforms.yawLeft
    job.edgeSide = orientation.transforms.yawRight
  else
    job.wallSide = orientation.transforms.yawRight
    job.edgeSide = orientation.transforms.yawLeft
  end
  job.above = false
  -- vertical alternating paths. stair tread level is false, two spaces up is true

  function job.setDirections()
    job.towardsNext = turtle.getFacing()
    job.towardsWall = orientation.getFacing(job.towardsNext, job.wallSide)
    job.towardsEdge = orientation.getFacing(job.towardsNext, job.edgeSide)
    job.towardsLast = orientation.getFacing(job.towardsEdge, job.edgeSide)
  end

  local function isFacing(direction)
    local facing = turtle.getFacing()
    return facing.x == direction.x and facing.z == direction.z
  end

  function job.isFacingNext()
    return isFacing(job.towardsNext)
  end

  function job.isFacingEdge()
    return isFacing(job.towardsEdge)
  end

  function job.isFacingWall()
    return isFacing(job.towardsWall)
  end

  function job.isFacingLast()
    return isFacing(job.towardsLast)
  end

  function job.isOnWall()
    return treadWidth == 1 or job.turn == job.towardsEdge
  end

  function job.isOnEdge()
    return treadWidth == 1 or job.turn == job.towardsWall
  end

  function job.initialize()
    job.setDirections()
    job.turn = job.towardsEdge
    -- start out oriented at the top step on the anchor wall side, so first turn will be toward the edge.
    job.startingPoint = location.create(turtle.getLocation())

    -- do this math once
    if job.length < (math.abs(job.height) * job.treadWidth) then
      if job.outside then
        job.wallPerRev = 0
        job.edgePerRev = 0
      else
        job.wallPerRev = 0
        job.edgePerRev = 0
      end
    end
  end
  return job
end

-- TODO: migrate this to inventory
function selectMaterialSlot(lower, upper, types)
  if turtle.getSelectedSlot() >= lower and turtle.getSelectedSlot() <= upper and turtle.getItemCount() > 0 then
    return true
  end
  -- TODO: check against list of acceptable item types

  for i = lower, upper do
    if turtle.getItemCount(i) > 0 then
      turtle.select(i)
      return true
    end
  end

  return false
end

-- TODO: migrate this to inventory
function resupply(slotLow, slotHigh, materialType)
  -- this could get tricky, since we can't count on there being any sort of
  -- clear vertical return route as there is in an excavation. This problem means
  -- code to walk up and down the stairs as part of the navigation.

  -- or just hang out until a human comes to do the resupply

  print("I'm out of stair stuff. Put it in slots 2-14!")
  repeat
    notification = { os.pullEvent() }
    event, p1 = table.unpack(notification)
    if event == "key" and p1 == 57 then
      exit()
    end
  until event == "turtle_inventory" and selectMaterialSlot(slotLow, slotHigh, materialType)
  print("Waiting 10 seconds for additional stuff...")
  os.sleep(10)
  print("Go time!")
end

-- TODO: migrate this to inventory
local function place(placeFunc, slotLow, slotHigh, materialType)
  if not selectMaterialSlot(slotLow, slotHigh, materialType) then
    resupply()
  end

  return placeFunc()
end

local function placeForward(slotLow, slotHigh, materialType)
  return place(turtle.place, turtle.detect, turtle.attack, slotLow, slotHigh, materialType)
end

local function placeUp(slotLow, slotHigh, materialType)
  return place(turtle.placeUp, slotLow, slotHigh, materialType)
end

local function placeDown(slotLow, slotHigh, materialType)
  return place(turtle.placeDown, slotLow, slotHigh, materialType)
end

function changeDirection(job)
  if job.turn == job.towardsWall then
    return job.towardsEdge
  end
  return job.towardsWall
end

function stepTraversal(job)
  runIntervalActions(job)
  if job.treadWidth > 1 then
    turtle.turnTo(job.turn)
  end

  local action = job.above and clearAirspace or layTread
  for i = 1, job.treadWidth do
    if i > 1 then
      turtle.forward()
    end
    action(job)
  end
  if job.treadWidth > 1 then
    job.turn = changeDirection(job)
    runIntervalActions(job)
    turtle.turnTo(job.turn)
  end
end

function layTread(job)
  -- this *should* only be possible on the first placement, since subsequent blocks will attach the the first
  if not placeDown(job.materialSlotRangeLow, job.materialSlotRangeHigh) then
    turtle.down()
    if job.stairsUp then
      -- this should always work since it would extend the previous step
      if not placeDown(job.materialSlotRangeLow, job.materialSlotRangeHigh) then
        local loc = turtle.getLocation()
        print(string.format("error anchoring to previous step at %d, %d, %d (relative)", loc.x, loc.y, loc.z))
      end
    else
      turtle.turnTo(job.towardsLast)
      -- this should always work since it would attach to the bottom of the previous step
      if not placeForward(job.materialSlotRangeLow, job.materialSlotRangeHigh) then
        local loc = turtle.getLocation()
        print(string.format("error anchoring to previous step at %d, %d, %d (relative)", loc.x, loc.y, loc.z))
      end
      turtle.turnTo(turn)
    end
    turtle.up()
    if not placeDown(job.materialSlotRangeLow, job.materialSlotRangeHigh) then
      local loc = turtle.getLocation()
      print(string.format("error placing tread at %d, %d, %d (relative)", loc.x, loc.y, loc.z))
      return false
    end
  end
  return true
end

function clearAirspace()
  turtle.digDown()
  turtle.digUp()
end

function runIntervalActions(job)
  if intervalActions then
    for _, action in pairs(job.intervalActions) do
      action(job)
    end
  end
end

function step(job, depth, corner)

  job.count = job.count + 1
  depth = depth or job.treadDepth

  if job.stairsUp then
    turtle.up()
  end

  for i = 1, depth do
    turtle.forward()
    if not job.stairsUp and i == 1 then
      turtle.down()
    end

    if not corner or job.outside then
      job.distance.wall = job.distance.wall + 1
    elseif not corner or not job.outside then
      job.distance.edge = job.distance.edge + 1
    end

    stepTraversal(job)
    if job.above then
      turtle.down()
      turtle.down()
    else
      turtle.up()
      turtle.up()
    end
    job.above = not job.above
    stepTraversal(job)
  end
end

local function flight(job, length)
  -- Assumes a start position facing the direction to create the flight
  -- of stairs, immediately in front of the first step, and next to the anchor
  -- wall. Initial turn should be away from the anchoring wall. This will be
  -- passed to intervalAction functions so they can orient themselves.

  local stepCount = math.floor(length / job.treadDepth)
  local remainderDepth = length % job.treadDepth

  local useDepth = job.treadDepth
  for i = 1, stepCount do
    if i == stepCount and remainderDepth > 0 then
      -- assume that a landing or other continuation makes a shallow final step ok.
      useDepth = remainderDepth
    end
    step(job, useDepth)
  end
end

function turnCorner(job)
  local direction = job.outside and job.towardsEdge or job.towardsWall
  turtle.turnTo(direction)
  -- if they're on the outside corner of the turn, move them to the edge of the next step
  if job.turn.x == direction.x and job.turn.z == direction.z then
    for j = 2, treadWidth do
      turtle.forward()
    end
  else
    job.turn = direction
  end
  -- update the relative directions to the edge, wall, next step and last step.
  job.setDirection()
end

-- Starting in front of the first step, immediately adjacent to the anchor wall.
-- Positive height value for stairs up, negative for down.
-- Table of interval actions that will be called as functions with the step job.count, current  job.turn, job.above, and initial  job.turn after each step.
function build(job)
  local totalCount = math.abs(height)
  if job.outside then
    -- flush landing
    turtle.up()
    step(job, job.treadWidth)
  end

  local activeLength = job.length
  while job.count < totalCount do
    flight(job, activeLength)
    activeLength = activeLength == job.length and  job.width or job.length
    if job.count < totalCount then
      step(job, job.treadWidth)
      turnCorner(job)
    end
  end
end


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
end

function placeRailings(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)

  return function(job)
    if above or job.isOnWall() then
      return true
    end

    local originalFacing = turtle.getFacing()
    turtle.turnTo(job.towardsEdge)
    local result = true
    if not turtle.detect() then
      turtle.forward()
      placeDown(job.materialSlotRangeLow, job.materialSlotRangeHigh, job.materialTypes)
      turtle.back()
      result = placeForward(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
    end

    turtle.turnTo(originalFacing)
    return result
  end
end


-- endregion
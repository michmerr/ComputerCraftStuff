-- region *.lua

if not utilities then
  dofile("utilities")
end

if not terp then
  os.loadAPI("terp")
end

if not location then
  os.loadAPI("location")
end

if not waypoint then
  os.loadAPI("waypointCollection")
end

function create(useInventory, minFuelForOperation, optimumTopOff, minFuelAfterReturn, fuelPoint, fuelPointSuckFunc)

  local waitForFuelLevel = minFuelForOperation or 500
  local takeFuelUntilLevel = optimumTopOff or waitForFuelLevel * 2
  local fuelPointLocation = fuelPoint
  if not fuelPointLocation then
    -- starting position, facing the other way
    fuelPointLocation = location.create(turtle.getLocation())
    fuelPointLocation.yawRight()
    fuelPointLocation.yawRight()
  end
  local refueling = false
  local fuelSafetyMargin = minFuelAfterReturn or 0
  local takeFuelFromInventory = useInventory or false

  local self = { }

  self.suckFuel = fuelPointSuckFunc

  function self.setWaitForFuelLevel(level)
    assert(level and type(level) == "number" and level > 0, "level must be a positive number")
    waitForFuelLevel = math.min(level, turtle.getFuelLimit())
    takeFuelUntilLevel = math.max(level, takeFuelUntilLevel)
    return true
  end

  function self.getWaitForFuelLevel()
    return waitForFuelLevel
  end

  function self.setRefueling(setting)
    assert(setting and type(setting) == "boolean", "setting must be a boolean value")
    refueling = setting
    return true
  end

  function self.getRefueling()
    return refueling
  end

  function self.setTakeFuelUntilLevel(level)
    assert(level and type(level) == "number" and level > 0, "level must be a positive number")
    takeFuelUntilLevel = math.min(level, turtle.getFuelLimit())
    return true
  end

  function self.getTakeFuelUntilLevel()
    return takeFuelUntilLevel
  end

  function self.setFuelSafetyMargin(level)
    assert(level and type(level) == "number" and level > 0, "level must be a positive number")
    fuelSafetyMargin = level
    return true
  end

  function self.getFuelSafetyMargin()
    return fuelSafetyMargin
  end

  function self.setFuelPointLocation(...)
    local args = { ...}
    assert((#args == 1 and type(args[1]) == "table") or(#args > 2 and #args < 5), "Expecting a waypoint/location object or constructor parameters for a waypoint.")
    if #args == 1 then
      fuelPointLocation = waypoint.new(args[1].label, args[1].x, args[1].y, args[1].z)
    elseif #args == 3 then
      fuelPointLocation = waypoint.new("fuel point", args[1], args[2], args[3])
    else
      fuelPointLocation = waypoint.new(...)
    end
    return true
  end

  -- returns a copy, so values are not changed in instances referenced for past locations
  function self.getFuelPointLocation()
    return waypoint.new(fuelPointLocation.label, fuelPointLocation.x, fuelPointLocation.y, fuelPointLocation.z)
  end

  function self.setTakeFuelFromInventory(setting)
    assert(setting and type(setting) == "boolean", "setting must be a boolean value")
    takeFuelFromInventory = setting
    return true
  end

  function self.getTakeFuelFromInventory()
    return takeFuelFromInventory
  end

  return self
end

local base = { }

-- Extend terp
for k, v in pairs(terp) do
  base[k] = v
end

local refuelConfig = create()
terp.refuelConfig = refuelConfig

function terp.refuelFromInventory(takeUntil)
  local takeAmount = takeUntil - terp.getFuelLevel()
  for slot = 1, 16 do
    if takeAmount <= 0 then
      break
    end
    terp.select(slot)
    terp.refuel(takeAmount)
    takeAmount = takeUntil - terp.getFuelLevel()
  end
end

-- TODO move to inventory
function returnItems(suckFunc, count)
  if suckFunc == terp.suck then
    return terp.drop(count)
  elseif suckFunc == terp.suckDown then
    return terp.dropDown(count)
  elseif suckFunc == terp.suckUp then
    return terp.dropUp(count)
  end

  print("Not sure what reciprocal drop function is for "..tostring(suckFunc))
  return false
end

function terp.tryPullFuel(suckFunc)
  suckFunc = suckFunc or terp.refuelConfig.suckFunc
  if not suckFunc then
    return false
  end

  local activeSlot = 0
  local counts = { }
  for i = 1, 16 do
    table.insert(counts, terp.getItemCount(i))
  end

  for i = 1, 16 do
    if counts[i] == 0 then
      terp.select(i)
      activeSlot = i
      break
    end
  end

  if terp.getItemCount() > 0 then
    print("No empty slots for fuel")
    return false
  end

  while terp.getFuelLevel() < terp.refuelConfig.getTakeFuelUntilLevel() and suckFunc(1) do
    if not terp.refuel() then
      print("item pulled from fuel point was not usable as fuel:" .. terp.getItemDetail().name)
      returnItems(suckFunc, 1)
      return false
    end
  end
end

function terp.waitForRefueling()
  -- operational minimum, plus fuel to get there and back
  local minFuel = terp.refuelConfig.getWaitForFuelLevel() + terp.howFar(terp.refuelConfig.getFuelPointLocation()) + terp.refuelConfig.getFuelSafetyMargin()

  if minFuel > terp.getFuelLimit() then
    minFuel = terp.getFuelimit()
  end

  local fuelLevel = 0

  -- optimistically planning on getting the optimum fuel level
  while fuelLevel < terp.refuelConfig.getTakeFuelUntilLevel() do

    tryPullFuel()
    fuelLevel = terp.getFuelLevel()
    -- wait for manual refuel
    if (utilities.waitForEvent(5, { "turtle_inventory" })) then
      refuelFromInventory(terp.refuelConfig.takeFuelUntilLevel())
    end
    os.sleep(3)
    -- Wait for the inventory events and fuel level changes to stop, to allow
    -- for manual addition of multiple fuel items and/or a charging station to
    -- continue charging. The inventory check

    if terp.getFuelLevel() > minFuel and terp.getFuelLevel() == fuelLevel then
      break
    end
  end
end

-- returns fuel temaining before return to the waypoint would be required
function terp.checkBingo(safetyMargin, waypoint)
  if not safetyMargin then
    safetyMargin = terp.refuelConfig.getFuelSafetyMargin()
  end

  safetyMargin = safetyMargin >= 0 and safetyMargin or 0

  if not waypoint then
    waypoint = terp.refuelConfig.getFuelPointLocation()
  end

  local distance = terp.howFar(waypoint)
  local bingoFuel = distance + safetyMargin
  return terp.getFuelLevel() - bingoFuel
end

function terp.useRefuelingPoint()
  terp.refuelConfig.setRefueling(true)
  local returnTo = terp.setWaypoint("resumeWork")
  if not terp.followWaypointsTo(terp.refuelConfig.getFuelPointLocation()) then
    return false
  end
  if not terp.waitForRefueling() then
    return false
  end

  if not terp.followWaypointsTo(returnTo) then
    return false
  end
  terp.removeWaypoint(returnTo)

  terp.refuelConfig.setRefueling(false)
  return true
end

function terp.triggerRefuel()
  if terp.refuelConfig.getRefueling() then
    return true
  end
  local bingo = terp.checkBingo()
  if bingo > 0 then
    return true
  end
  if terp.refuelConfig.getTakeFuelFromInventory() then
    refuelFromInventory(terp.refuelConfig.getTakeFuelUntilLevel())
    if terp.checkBingo() > 0 then
      return true
    end
  end

  return terp.useRefuelingPoint()
end

function terp.forward()
  if not terp.triggerRefuel() then
    return false
  end
  return base.forward()
end


function terp.up()
  if not terp.triggerRefuel() then
    return false
  end
  return base.up()
end

function terp.down()
  if not terp.triggerRefuel() then
    return false
  end
  return base.down()
end

function terp.back()
  if not terp.triggerRefuel() then
    return false
  end
  return base.back()
end


-- endregion

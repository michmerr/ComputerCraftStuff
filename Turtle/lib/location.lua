-- region *.lua
-- Date

if not terp then
  os.loadAPI("/terp/lib/terp")
end

if not orientation then
  os.loadAPI("/terp/lib/orientation")
end

if not Logger then
  os.loadAPI("/terp/lib/Logger")
end

function create(state)

  local self = orientation.create(state and state.attitude)

  local x = state and state.x or 0
  local y = state and state.y or 0
  local z = state and state.z or 0

  local function move(dx, dy, dz)
    x = x + dx
    y = y + dy
    z = z + dz
    return self.getLocation()
  end

  function self.moveForward()
    return move(self.translateForward())
  end

  function self.moveBack()
    return move(self.translateBackward())
  end

  function self.moveUp()
    return move(self.translateUp())
  end

  function self.moveDown()
    return move(self.translateDown())
  end

  function self.moveLeft()
    return move(self.translateLeft())
  end

  function self.moveRight()
    return move(self.translateRight())
  end

  function self.getLocation()
    return {
      attitude = self.getState();
      x = x;
      y = y;
      z = z
      }
  end

  -- Distance to coords in right-angle moves
  function self.howFar(x1, y1, z1)
    return math.abs(x - x1) + math.abs(y - y1) + math.abs(z - z1)
  end

  return self
end


local _location = create()

local function wrapMovementFunction(wrapFunc, locFunc, funcName)
  return function(...)
    Logger.log(Logger.levels.DEBUG, "terp.%s()", funcName)
    local result, err = wrapFunc(...)
    if result then
      locFunc()
    end
    local loc = terp.getLocation()
    Logger.log(Logger.levels.DEBUG, "location now, %d,%d,%d facing %s", loc.x, loc.y, loc.z, tostring(loc.attitude))
    return result, err
  end
end

for _, direction in pairs({ "Up", "Down", "Forward", "Back" }) do
  local funcName = string.lower(direction)
  terp[funcName] = wrapMovementFunction(terp[funcName], _location["move" .. direction], funcName)
end

for _, direction in pairs({ "Right", "Left" }) do
  terp["turn" .. direction] = wrapMovementFunction(terp["turn" .. direction], _location["yaw" .. direction], direction)
end

terp.getLocation = _location.getLocation
terp.howFar = _location.howFar
terp.getFacing = _location.getFacing

function terp.turnTo(targetOrientation)
  Logger.log(Logger.levels.DEBUG, "turnTo: %s", tostring(targetOrientation))
  local facing = terp.getFacing()
  if facing == targetOrientation then
    return true
  end
  local delta = targetOrientation
  if facing ~= orientation.transforms.neutral then
    delta = targetOrientation * orientation.transforms.reverseYaw
    if facing ~= orientation.transforms.reverseYaw then
      delta = delta * facing
    end
  end
  Logger.log(Logger.levels.DEBUG, "delta = %s", tostring(delta))
  if delta == orientation.transforms.reverseYaw then
    terp.turnAround()
  elseif delta == orientation.transforms.yawRight then
    terp.turnRight()
  else
    terp.turnLeft()
  end
end

function terp.moveTo(x, y, z)
  local start = _location.getLocation()
  local facing
  if type(x) == "table" then
    if x.x and x.y and x.z then
      y = x.y
      z = x.z
      x = x.x
      if x.attitude then
        facing = x.attitude
      end
    elseif #x == 3 then
      y = x[2]
      z = x[3]
      x = x[1]
    else
      error("Arguments must be x, y, z; a table with x, y, z keys; or a list of three numbers")
    end
  end

  dX = x - start.x
  dY = y - start.y
  dZ = z - start.z

  if dZ ~= 0 then
    terp.turnTo(dZ > 0 and orientation.transforms.neutral or orientation.transforms.reverseYaw)
    for i = 1, math.abs(dZ) do
      terp.forward()
    end
  end
  if dX ~= 0 then
    terp.turnTo(dX > 0 and orientation.transforms.yawRight or orientation.transforms.yawLeft)
    for i = 1, math.abs(dX) do
      terp.forward()
    end
  end

  local verticalMove
  if dY > 0 then
    verticalMove = terp.up
  elseif dY < 0 then
    verticalMove = terp.down
  end
  for i = 1, math.abs(dY) do
    verticalMove()
  end

  if facing then
    terp.turnTo(facing)
  end

end

-- endregion

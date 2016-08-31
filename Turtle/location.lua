-- region *.lua
-- Date

if not orientation then
  os.loadAPI("orientation")
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
      attitude = getOrientationState();
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

local function wrapMovementFunction(wrapFunc, locFunc)
  return function(...)
    local result = wrapFunc(...)
    if result then
      locFunc()
    end
    return result
  end
end

for _, direction in pairs({ "Up", "Down", "Forward", "Back" }) do
  local funcName = string.lower(direction)
  turtle[funcName] = wrapMovementFunction(turtle[funcName], _location["move" .. direction])
end

for _, direction in pairs({ "Right", "Left" }) do
  turtle["turn" .. direction] = wrapMovementFunction(turtle["turn" .. direction], _location["yaw" .. direction])
end

turtle.getLocation = _location.getLocation
turtle.howFar = _location.howFar
turtle.getFacing = _location.getFacing

function turtle.turnTo(x, z)
  if type(x) == "table" then
    assert(x.x and x.z)
    z = x.z
    x = x.x
  end

  if math.abs(x) == math.abs(z) then
    error("90 degree directions only. One value must be 0, and the other must be positive or negative to indicate the facing along that axis.")
  end

  local fX, fY, fZ = _location.getFacing()

  if (z < 0) then
    if facing.x > 0 then
      turtle.turnRight()
    elseif facing.x < 0 then
      turtle.turnLeft()
    elseif facing.z > 0 then
      turtle.turnRight()
      turtle.turnRight()
    end
  elseif (z > 0) then
    if facing.x == 1 then
      turtle.turnLeft()
    elseif facing.x == -1 then
      turtle.turnRight()
    elseif facing.z < 0 then
      turtle.turnRight()
      turtle.turnRight()
    end
  elseif (x > 0) then
    if facing.z > 0 then
      turtle.turnRight()
    elseif facing.z < 0 then
      turtle.turnLeft()
    elseif facing.x > 0 then
      turtle.turnRight()
      turtle.turnRight()
    end
  elseif (x < 0) then
    if facing.z == 1 then
      turtle.turnLeft()
    elseif facing.z == -1 then
      turtle.turnRight()
    elseif facing.x < 0 then
      turtle.turnRight()
      turtle.turnRight()
    end
  end
end

function turtle.moveTo(x, y, z)
  local start = _location.getLocation()

  if type(x) == "table" then
    if x.x and x.y and x.z then
      y = x.y
      z = x.z
      x = x.x
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
    turnTo(0, dZ)
    for i = 1, math.abs(dZ) do
      turtle.forward()
    end
  end
  if dX ~= 0 then
    turnTo(dX, 0)
    for i = 1, math.abs(dX) do
      turtle.forward()
    end
  end

  local verticalMove
  if dY > 0 then
    verticalMove = turtle.up
  elseif dY < 0 then
    verticalMove = turtle.down
  end
  for i = 1, math.abs(dY) do
    verticalMove()
  end
end

-- endregion

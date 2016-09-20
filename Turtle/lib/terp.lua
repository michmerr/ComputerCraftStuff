-- region *.lua
-- Date

if not turtle then
  os.loadAPI("/terp/lib/turtle")
end

if not Logger then
  os.loadAPI("/terp/lib/Logger")
end

local base = { }

DIG_FAILED = "Block detected, but dig failed. Move aborted."
OUT_OF_FUEL = "Out of fuel"
MOVE_FAILED = "Movement after negative detect failed after %d attempts"
PLACE_FAILED = "Place failed for unknown reason."

-- Extend turtle as a baseline
local loadContext = getfenv()
for k, v in pairs(turtle) do
  loadContext[k] = v
end

function turnAround()
  return terp.turnRight() and terp.turnRight()
end

function detectRight()
  turtle.turnRight()
  local result = turtle.detect()
  turtle.turnLeft()
  return result
end

function detectLeft()
  turtle.turnLeft()
  local result = turtle.detect()
  turtle.turnRight()
  return result
end

function detectBack()
  turnAround()
  local result = turtle.detect()
  turnAround()
  return result
end

local function move(moveFunc, detectFunc, digFunc, attackFunc)
  local counter = 0
  while not moveFunc() do
    if detectFunc() then
      if not digFunc() then
        return false, DIG_FAILED
      end
    elseif turtle.getFuelLevel() == 0 then
      return false, OUT_OF_FUEL
    elseif not attackFunc() then
      if counter > 10 then
        -- something's wrong
        return false, string.format(MOVE_FAILED, counter)
      end
      -- falling block after previous dig
      os.sleep(0.2)
    end
  end
  return true
end

local function _place(placeFunc, detectFunc, attackFunc)
  if placeFunc() then
    return true
  end

  if detectFunc() then
    return false
  end

  if not attackFunc() then
    return false, PLACE_FAILED
  end

  while attackFunc() do
    os.sleep(0.2)
  end

  -- in case mob changed environment (e.g. creeper explosion)
  return _place(placeFunc, detectFunc, attackFunc)
end

function dig()
  return turtle.detect() and turtle.dig()
end

function digUp()
  return turtle.detectUp() and turtle.digUp()
end

function digDown()
  return turtle.detectDown() and turtle.digDown()
end

function place()
  return _place(turtle.place, turtle.detect, turtle.attack)
end

function placeDown()
  return _place(turtle.placeDown, turtle.detectDown, turtle.attackDown)
end

function placeUp()
  return _place(turtle.placeUp, turtle.detectUp, turtle.attackUp)
end

function forward()
  return move(turtle.forward, turtle.detect, turtle.dig, turtle.attack)
end

function back(failOk)
  local result = turtle.back()
  if not result and not failOk then
    turnAround()
    result = forward()
    turnAround()
  end
  return result;
end

function up()
  return move(turtle.up, turtle.detectUp, turtle.digUp, turtle.attackUp)
end

function down()
  return move(turtle.down, turtle.detectDown, turtle.digDown, turtle.attackDown)
end

function right(distance)
  local result = true
  turtle.turnRight()
  for i = 1, distance or 1 do
    if not forward() then
      result = false
      break
    end
  end
  turtle.turnLeft()
  return result;
end

function left(distance)
  local result = true
  turtle.turnLeft()
  for i = 1, distance or 1 do
    if not forward() then
      result = false
      break
    end
  end
  turtle.turnRight()
  return result;
end


-- endregion
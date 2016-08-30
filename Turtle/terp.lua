-- region *.lua
-- Date

if not turtle then
  os.loadAPI("turtle")
end

local base = { }

-- Extend turtle
for k, v in pairs(turtle) do
  base[k] = v
end

function turtle.turnAround()
  return turtle.turnRight() and turtle.turnRight()
end

function turtle.detectRight()
  turtle.turnRight()
  local result = turtle.detect()
  turtle.turnLeft()
  return result
end

function turtle.detectLeft()
  turtle.turnLeft()
  local result = turtle.detect()
  turtle.turnRight()
  return result
end

function turtle.detectBack()
  turtle.turnAround()
  local result = turtle.detect()
  turtle.turnAround()
  return result
end

local function move(moveFunc, detectFunc, digFunc, attackFunc)
  if detectFunc() then
    if not digFunc() then
      return false
    end
  end
  while not moveFunc() do
    if detectFunc() then
      if not digFunc() then
        return false
      end
    elseif not attackFunc() then
      -- falling block after previous dig
      os.sleep(0.2)
    end
  end
end

function turtle.forward()
  return move(baseforward, basedetect, turtle, dig, baseattack)
end

function turtle.back()
  local result = baseback()
  if not result then
    turtle.turnAround()
    result = turtle.forward()
    turtle.turnAround()
  end
  return result;
end

function turtle.up()
  return move(baseup, basedetectUp, turtle, digUp, baseattackUp)
end

function turtle.down()
  return move(basedown, basedetectDown, turtle, digDown, baseattackDown)
end

function turtle.right(distance)
  local result = true
  turtle.turnRight()
  for i = 1, distance or 1 do
    if not turtle.forward() then
      result = false
      break
    end
  end
  turtle.turnLeft()
  return result;
end

function turtle.left(distance)
  local result = true
  turtle.turnLeft()
  for i = 1, distance or 1 do
    if not turtle.forward() then
      result = false
      break
    end
  end
  turtle.turnRight()
  return result;
end


-- endregion
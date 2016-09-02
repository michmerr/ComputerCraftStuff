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
  local counter = 0
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
      if counter > 10 then
        -- something's wrong
        print("Movement after negative detect failed after "..counter.." attempts")
        return false
      end
      -- falling block after previous dig
      os.sleep(0.2)
    end
  end
  return true
end

local function place(placeFunc, detectFunc, attackFunc)
    if detectFunc() then
        return false
    end
    if placeFunc() then
      return true
    end

    if attackFunc() then
        repeat
            print("Mob blocking placement")
        until not attackFunc()
        print("Mob cleared")
        if placeFunc() then
            return true
        end
    end
    return false

end

function turtle.place()
  return place(base.place, base.detect, base.attack)
end

function turtle.placeDown()
  return place(base.placeDown, base.detectDown, base.attackDown)
end

function turtle.placeUp()
  return place(base.placeUp, base.detectUp, base.attackUp)
end

function turtle.forward()
  return move(base.forward, base.detect, turtle.dig, base.attack)
end

function turtle.back()
  local result = base.back()
  if not result then
    turtle.turnAround()
    result = turtle.forward()
    turtle.turnAround()
  end
  return result;
end

function turtle.up()
  return move(base.up, base.detectUp, turtle, digUp, base.attackUp)
end

function turtle.down()
  return move(base.down, base.detectDown, turtle, digDown, base.attackDown)
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
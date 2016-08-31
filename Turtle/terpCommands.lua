-- region *.lua
-- Date
if not terp then
  os.loadAPI("terp")
end
if not utilities then
  dofile("utilities")
end
if not stairs then os.loadAPI("stairs") end


function digAboveBelow(digPrevious, digNext)
  local result = true
  if digPrevious then
    result = digPrevious()
  end
  if digNext then
    result = digNext() and result
  end
  return result
end

function digLayer(length, width, thickness, turn)

  thickness = thickness or 3
  turn = turn or turtle.turnRight

  if thickness == 0 then
    return turn
  end

  local absoluteThickness = math.abs(thickness)
  local digNext = thickness > 0 and turtle.digDown or turtle.digUp
  local digPrevious = thickness < 0 and turtle.digDown or turtle.digUp
  local moveStart = thickness > 0 and turtle.down or turtle.up

  if absoluteThickness < 3 then
    digPrevious = nil
  end

  if absoluteThickness < 2 then
    digNext = nil
    moveStart = nil
  end

  local verticalLimit =(not moveStart or not moveStart()) or(digNext and not digNext())

  if verticalLimit then
    digNext = nil
  end

  for j = 1, width do
    for k = 1, length do
      if not digAboveBelow(digPrevious, digNext) then
        return nil, "Failed to dig up or down"
      end
      if not turtle.forward() then
        return nil, "Failed to move forward"
      end
    end
    if not digAboveBelow(digPrevious, digNext) then
      return nil, "Failed to dig up or down"
    end
    -- don't turn at the end of the last row. Let the calling function determine the pattern from layer to layer.
    if j < width then
      turn()
      if not turtle.forward() then
        return nil, "Failed to move forward"
      end
      turn()
      if turn == turtle.turnLeft then
        turn = turtle.turnRight
      else
        turn = turtle.turnLeft
      end
    end
  end

  return turn, verticalLimit
end

function offset(lateral, forward, vertical)
  if not lateral and not forward and not vertical then
    return true
  end

  if lateral then
    if lateral > 0 then
      if not turtle.right(lateral) then
        return false
      end
    elseif (lateral < 0) then
      if not turtle.left(lateral * -1) then
        return false
      end
    end
  end

  if forward then
    if forward > 0 then
      for i = 1, forward do
        if not turtle.forward() then
          return false
        end
      end
    elseif (forward < 0) then
      for i = 1, forward * -1 do
        if not turtle.reverse() then
          return false
        end
      end
    end
  end

  if vertical then
    if vertical > 0 then
      for i = 1, vertical do
        if not turtle.up() then
          return false
        end
      end
    elseif (forward < 0) then
      for i = 1, vertical * -1 do
        if not turtle.down() then
          return false
        end
      end
    end
  end

  return true
end

function tunnel(length, width, height, lateral_offset, horizontal_offset, vertical_offset)
  assert(length, "length must be a positive number.")
  assert(not width or width > 0, "width must be a positive number.")
  assert(not width or height > 0, "height must be a positive number.")

  width = width or 1
  height = height or 2
  lateral_offset = lateral_offset or 0

  -- Center the tunnel on the reference point
  local offset = math.floor(width / 2)

  assert(offset(lateral_offset - offset, horizontal_offset, vertical_offset + 1), "failed to move to offset starting position")

  local turn = turtle.rightTurn
  for i = height, 1, -3 do
    turn = assert(digLayer(length, width, i > 2 and -3 or i * -1, turn))
    -- Instead of an alternating quarry pattern, keep all layer patterns oriented down the length of the tunnel
    -- to reduce the number of turns.
    turtle.turnAround()
    for j = 1, math.min(i, 2) do
      assert(turtle.up(), "failed upward move to next layer")
    end
  end
  return true
end

function digHole(length, width, depth, lateral_offset, horizontal_offset, vertical_offset)

  if not length or not width then
    error("length and width values cannot be nil")
  end

  if not offset(lateral_offset, horizontal_offset, vertical_offset) then
    return false
  end

  local turn = turtle.rightTurn
  local crossPattern = length == width
  local err
  for i = depth, 1, -3 do
    turn, err = digLayer(length, width, i > 2 and -3 or i * -1, turn)
    if crossPattern then
      if turn == turtle.turnLeft then
        turn = turtle.turnRight
      else
        turn = turtle.turnLeft
      end
    else
      turn()
    end
    turn()
    if i > 2 then
      assert(turtle.digDown(), "failed to move down into area cleared by last pass.")
    end
    for j = 1, math.min(2, i) do
      if not turtle.down() then
        print("I think we've hit bottom!")
        i = 3 + j
        break;
      end
    end
  end
end

function sealSides(length, width, depth, lateral_offset, horizontal_offset, vertical_offset, materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
  local digNext = thickness > 0 and turtle.digDown or turtle.digUp
  local digPrevious = thickness < 0 and turtle.digDown or turtle.digUp
  local move = depth > 0 and turtle.down or turtle.up
  turtle.turnLeft()
  local activeSide = length
  for k = 1, 4 do
    for i = 1, activeSide do
      for j = 1, math.abs(depth) do
        stairs.placeForward(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
        if not move() then
          break
        end
      end
      turtle.right()
      move = move == turtle.down and turtle.up or turtle.down
    end
    activeSide = activeSide == length and width or length
    turtle.turnRight()
  end
end

function sealFlat(length, width, overhead, lateral_offset, horizontal_offset, vertical_offset, materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
  local turn = width > 0 and turtle.turnRight or turtle.turnLeft
  local place = overhead and stairs.placeUp or stairs.placeDown
  if not offset(lateral_offset, horizontal_offset, vertical_offset) then
    return false
  end
  for i = 1, math.abs(width) do
    for j = 1, length do
      place(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
      turtle.forward()
    end
    turn()
    if i < math.abs(width) then
      turtle.forward()
      turn()
      turn = turn == turtle.turnLeft and turtle.turnRight or turtle.turnLeft
    end
  end
  turn()
  return true
end

function seal(length, width, depth, lateral_offset, horizontal_offset, vertical_offset)
  if not offset(lateral_offset, horizontal_offset, vertical_offset) then
    return false
  end
  assert(false, "TODO")
end

-- endregion

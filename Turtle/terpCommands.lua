-- region *.lua
-- Date
if not terp then
  os.loadAPI("terp")
end
if not utilities then
  dofile("utilities")
end
if not stairs then
  os.loadAPI("stairs")
end

directionFuncs = {
  forward = {
    move = turtle.forward;
    dig = turtle.dig;
    place = stairs.place;
    detect = turtle.detect;
    attack = turtle.attack;
    inspect = turtle.inspect;
    drop = turtle.drop;
    suck = turtle.suck;
    };
  up = {
    move = turtle.up;
    dig = turtle.digUp;
    place = stairs.placeUp;
    detect = turtle.detectUp;
    attack = turtle.attackUp;
    inspect = turtle.inspectUp;
    drop = turtle.dropUp;
    suck = turtle.suckUp;
     };
  down = {
    move = turtle.down;
    dig = turtle.digDown;
    place = stairs.placeDown;
    detect = turtle.detectDown;
    attack = turtle.attackDown;
    inspect = turtle.inspectDown;
    drop = turtle.dropDown;
    suck = turtle.suckDown;
    };
  back = {
    move = turtle.back;
    detect = turtle.detectBack;
    place = function(...)
      turtle.turnAround()
      local result = stairs.place(...)
      turtle.turnAround()
      return result
    end;
  }
}

local spinFuncs = {
  yaw = {
    { turnNext = turtle.turnRight; turnBack = nil; place = directionFuncs.forward.place };
    { turnNext = turtle.turnRight; turnBack = turtle.turnLeft; place = directionFuncs.forward.place };
    { turnNext = turtle.turnRight; turnBack = turtle.turnAround; place = directionFuncs.forward.place };
    { turnNext = turtle.turnRight; turnBack = turtle.turnRight; place = directionFuncs.forward.place };
  };
  roll = {
    { turnNext = nil; turnBack = nil; place = directionFuncs.up.place };
    { turnNext = turtle.turnRight; turnBack = nil; place = directionFuncs.down.place };
    { turnNext = turtle.turnAround; turnBack = turtle.turnLeft; place = directionFuncs.forward.place };
    { turnNext = turtle.turnRight; turnBack = turtle.turnRight; place = directionFuncs.forward.place };
  };
}

directionFuncs.forward.spinAxis = spinFuncs.roll
directionFuncs.forward.opposite = directionFuncs.back

directionFuncs.up.spinAxis = spinFuncs.yaw
directionFuncs.up.opposite = directionFuncs.down

directionFuncs.down.spinAxis = spinFuncs.yaw
directionFuncs.down.opposite = directionFuncs.up

local anchorDirections = {
  up = { funcs = directionFuncs.up; spin = spinFuncs.yaw };
  down = { funcs = directionFuncs.down; spin = spinFuncs.yaw };
  forward = { funcs = directionFuncs.forward; spin = spinFuncs.roll };
}


-- Dig up and down if the functions are passed.
-- Allows three layers per pass, with optional trimming of the up or down to hit
-- specific depth numbers.
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

-- Dig a horizontal layer.
function digLayer(length, width, thickness, turn)

  thickness = thickness or 3
  assert(thickness >= -3 and thickness <= 3, "Layer thickness can be a maximum of 3 in either direction")
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

-- move to an offset starting position
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

-- dig a horizontal tunnel with the center of its base at the start position
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

-- dig down...or up.
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

-- spin around an axis, running a script on each of the four sides. on the first success, return
-- to original facing and return true. return failure if the start position is reached without success.
local function spinTryAny(axis, func)
  for i = 1, 4 do
    if func(axis[i]) then
      if axis[i].turnBack then
        axis[i].turnBack()
      end
      return true
    end
    if axis[i].turnNext then
      axis[i].turnNext()
    end
  end
  return false
end

-- Try to place a block in any of the four positions around the axis of travel
function spinPlaceAny(axis, materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
  return spinTryAny(
    axis,
    function(direction)
      return direction.place(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
    end
    )
end

-- from a position where you want to place a block, try building a stack of blocks in the direction from which you came.
-- upon success, move around the desired block, remove the stack of blocks, and end in position adjacent to the block.
function placeBootstrap(anchorDirection, directionOfTravel, materialSlotRangeLow, materialSlotRangeHigh, materialTypes, limit)

  local step = 0

  local result = anchorDirection.opposite.place(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
  if not result then
    while step < limit do
      anchorDirection.opposite.move()
      step = step + 1
      if anchorDirection.opposite.place(materialSlotRangeLow, materialSlotRangeHigh, materialTypes) then
        result = true
        break
      end
    end
    for i = 1, step do
      anchorDirection.move()
      if result then
        anchorDirection.opposite.place(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
      end
    end
  end

  -- move around the newly placed block and back into the start position
  if result then
    directionOfTravel.move()
    anchorDirection.opposite.move()
    directionOfTravel.opposite.move()

    -- remove bootstrap blocks
    for i = 1, step do
      anchorDirection.opposite.move()
    end
    for i = 1, step do
      anchorDirection.move()
    end
  end

  return result
end

function tryPlaceFoundation(anchorDirection, directionOfTravel, materialSlotRangeLow, materialSlotRangeHigh, materialTypes, limit, first)
  if anchorDirection.detect() or anchorDirection.place(materialSlotRangeLow, materialSlotRangeHigh, materialTypes) then
    return true
  end
  if not first then
    first = limit
  end
  anchorDirection.move()

  local result = anchorDirection.place(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
    or spinPlaceAny(anchorDirection.spin, materialSlotRangeLow, materialSlotRangeHigh, materialTypes)

  if not result and first == limit then
    if placeBootstrap(anchorDirection, directionOfTravel, materialSlotRangeLow, materialSlotRangeHigh, materialTypes, limit) then
      return true
    end
  end

  if not result and limit > 1 then
    result = tryPlaceFoundation(anchorDirection, directionOfTravel, materialSlotRangeLow, materialSlotRangeHigh, materialTypes, limit - 1, first)
  end

  -- if no anchors are found along the primary axis (i.e. up, when placing up), try checking perpendicular to that axis in the four basic directions.
  if not result and first == limit then
    result = spinTryAny(
      anchorDirection.spin == spinFuncs.yaw and spinFuncs.roll or spinFuncs.yaw,
      function(axis)
        return tryPlaceFoundation(axis.funcs, directionOfTravel, materialSlotRangeLow, materialSlotRangeHigh, materialTypes, limit, first + 1)
      end
      )

    if result then
      result = anchorDirection.place(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
    end
  end

  anchorDirection.opposite.move()
  return result
end

-- seal (or lay) a flat surface, either above or below
function sealFlat(length, width, direction, lateral_offset, horizontal_offset, vertical_offset, materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
  local turn = width > 0 and turtle.turnRight or turtle.turnLeft
  if not offset(lateral_offset, horizontal_offset, vertical_offset) then
    return false, "failed to move to start mosition"
  end
  -- if the first one is good, the rest will connect the preceding block.
  if not direction.place(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
    and not tryPlaceFoundation(direction, directionFuncs.forward, materialSlotRangeLow, materialSlotRangeHigh, materialTypes, 5) then
    return false, "could not place initial block"
  end

  for i = 1, math.abs(width) do
    for j = 1, length do
      direction.place(materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
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

-- seal the sides of a vertical shaft
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

-- seal the sides and (optionally) top and bottom of a box
function seal(length, width, depth, top, bottom, lateral_offset, horizontal_offset, vertical_offset, materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
  if not offset(lateral_offset, horizontal_offset, vertical_offset) then
    return false
  end
  local bottomOffset = depth > 0 and (depth * -1) or depth
  local topOffset = depth > 0 and -1 or depth
  result = sealSides(length, width, depth, 0, 0, 0, materialSlotRangeLow, materialSlotRangeHigh, materialTypes)
    and (not bottom or sealFlat(length, width, 0, 0, bottomOffset, materialSlotRangeLow, materialSlotRangeHigh, materialTypes))
    and (not top or sealFlat(length, width, 0, 0, topOffset, materialSlotRangeLow, materialSlotRangeHigh, materialTypes))

  return result
end

-- endregion

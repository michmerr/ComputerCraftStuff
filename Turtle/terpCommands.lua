-- region *.lua
-- Date

if not utilities then
  if require then
    require("utilities")
  else
    dofile("utilities")
  end
end

utilities.require("terp")

function decorate(terpTarget)

  function digAboveBelow(digPrevious, digNext)
    if digPrevious then
      if not digPrevious() then
        return false
      end
    end
    if digNext then
      if not digNext() then
        return false
      end
    end
    return true
  end

  function terpTarget.digLayer(length, width, thickness, turn)

    thickness = thickness or 3
    turn = turn or terpTarget.turnRight

    if thickness == 0 then
      return turn
    end

    local absoluteThickness = math.abs(thickness)
    local digNext = thickness > 0 and terpTarget.digDown or terpTarget.digUp
    local digPrevious = thickness < 0 and terpTarget.digDown or terpTarget.digUp
    local moveStart = thickness > 0 and terpTarget.down or terpTarget.up

    if absoluteThickness < 3 then
      digPrevious = nil
    end

    if absoluteThickness < 2 then
      digNext = nil
      moveStart = nil
    end

    local verticalLimit = (not moveStart or not moveStart()) or (digNext and not digNext())

    if verticalLimit then
      digNext = nil
    end

    for j = 1, width do
      for k = 1, length do
        if not digAboveBelow(digPrevious, digNext) then
          return nil, "Failed to dig up or down"
        end
        if not terpTarget.forward() then
          return nil, "Failed to move forward"
        end
      end
      if not digAboveBelow(digPrevious, digNext) then
        return nil, "Failed to dig up or down"
      end
      -- don't turn at the end of the last row. Let the calling function determine the pattern from layer to layer.
      if j < width then
        turn()
        if not terpTarget.forward() then
          return nil, "Failed to move forward"
        end
        turn()
        if turn == terpTarget.turnLeft then
          turn = terpTarget.turnRight
        else
          turn = terpTarget.turnLeft
        end
      end
    end

    return turn, verticalLimit
  end

  function terpTarget.offset(lateral, forward, vertical)
    if not lateral and not forward and not vertical then
      return true
    end

    if lateral then
      if lateral > 0 then
        if not terpTarget.right(lateral) then
          return false
        end
      elseif (lateral < 0) then
        if not terpTarget.left(lateral * -1) then
          return false
        end
      end
    end

    if forward then
      if forward > 0 then
        if not terpTarget.forward(forward) then
          return false
        end
      elseif (forward < 0) then
        if not terpTarget.reverse(forward * -1) then
          return false
        end
      end
    end

    if vertical then
      if vertical > 0 then
        if not terpTarget.up(vertical) then
          return false
        end
      elseif (forward < 0) then
        if not terpTarget.down(vertical * -1) then
          return false
        end
      end
    end

    return true
  end

  function terpTarget.tunnel(length, width, height, lateral_offset, horizontal_offset, vertical_offset)
    assert(length, "length must be a positive number.")
    assert(not width or width > 0, "width must be a positive number.")
    assert(not width or height > 0, "height must be a positive number.")

    width = width or 1
    height = height or 2
    lateral_offset = lateral_offset or 0

    -- Center the tunnel on the reference point
    local offset = math.floor(width / 2)

    assert(terpTarget.offset(lateral_offset - offset, horizontal_offset, vertical_offset + 1), "failed to move to offset starting position")

    local turn = terpTarget.rightTurn
    for i = height, 1, -3 do
      turn = assert(terpTarget.digLayer(length, width, i > 2 and -3 or i * -1, turn))
      -- Instead of an alternating quarry pattern, keep all layer patterns oriented down the length of the tunnel
      -- to reduce the number of turns.
      terpTarget.turnAround()
      for j = 1, math.min(i, 2) do
        assert(terpTarget.up(), "failed upward move to next layer")
      end
    end
    return true
  end

  function terpTarget.hole(length, width, depth, lateral_offset, horizontal_offset, vertical_offset)

    if not length or not width then
      error("length and width values cannot be nil")
    end

    if not terpTarget.offset(lateral_offset, horizontal_offset, vertical_offset) then
      return false
    end

    local turn = terpTarget.rightTurn
    local crossPattern = length == width
    local err
    for i = depth, 1, -3 do
      turn, err = terpTarget.digLayer(length, width, i > 2 and -3 or i * -1, turn)
      if t
      if crossPattern then
        if turn == terpTarget.turnLeft then
          turn = terpTarget.turnRight
        else
          turn = terpTarget.turnLeft
        end
      else
        turn()
      end
      turn()
      if i > 2 then
        assert(terpTarget.digDown(), "failed to move down into area cleared by last pass.")
      end
      for j = 1, math.min(2, i) do
        if not terpTarget.down() then
      end
    end
  end

  function terpTarget.sealSides(length, width, depth, lateral_offset, horizontal_offset, vertical_offset)

  end

  function terpTarget.sealFlat(length, width, depth, lateral_offset, horizontal_offset, vertical_offset)

  end

  function terpTarget.seal(length, width, depth, lateral_offset, horizontal_offset, vertical_offset)
    if not terpTarget.offset(lateral_offset, horizontal_offset, vertical_offset) then
      return false
    end
    assert(false, "TODO")
  end
end
-- endregion

-- region *.lua
-- Date
if not utilities then
  dofile("/terp/utilities")
end

function flush()
  local side = 1
  for i = 1, 16 do
    if turtle.getItemCount(i) > 0 then
      turtle.select(i)
      while not((side < 5 and turtle.drop()) or(side == 5 and turtle.dropDown())) do
        turtle.turnLeft()
        if side > 4 then
          return false
        end
        side = side + 1
      end
    end
  end
  return true
end

local waitResult

while true do
  while not flush() do
    print "Waiting for outputs to be cleared"
    waitResult = utilities.waitForEvent(30, { "key" })
    if waitResult and waitResult[2] == 57 then
      return
    end
  end

  repeat
    turtle.suckUp()
    waitResult = utilities.waitForEvent(1, { "key" })
    if waitResult then
      if waitResult[2] == 57 then
        return
      end
      break
    end
  until turtle.getItemCount(16) > 0

end
-- endregion

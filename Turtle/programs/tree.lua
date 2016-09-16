--- scratchpad with blocks from two quick and dirty script written in the field
--- will not run as is
return false
---

local y1 = 0
while not turtle.detectUp() do
  turtle.up()
  y1 = y1 + 1
end

local y = 0
function move(detect, dig, move, dy)
  while detect() do
    dig()
  end
  if turtle.detect() then
    turtle.dig()
  end
  move()
  y = y + dy
end

function up()
  repeat
    move(turtle.detectUp, turtle.digUp, turtle.up, 1)
  until not turtle.detectUp()

  while turtle.detect() do
    move(turtle.detectUp, turtle.digUp, turtle.up, 1)
  end
end

function down()
  while y > 0 do
    move(turtle.detectDown, turtle.digDown, turtle.down, -1)
  end
end

local turn = turtle.turnRight


while turtle.detectUp() do
  while turtle.detectUp() do
    up()
    turtle.forward()
    turtle.dig()
    turtle.forward()
    down()
    turtle.dig()
    turtle.forward()
    turtle.dig()
    turtle.forward()
  end
  turn()
  turtle.dig()
  turtle.forward()
  turn()
  if turn == turtle.turnLeft then
    turn = turtle.turnRight
  else
    turn = turtle.turnLeft
  end

  for i = 1,7 do
    if turtle.detect() then
      turtle.dig()
    end
    turtle.forward()
    if turtle.detectUp() then
      break
    end
  end
end

for j = 1, y1 do
  down()
end

-----------


local y = 0
while not turtle.detectUp() and y < 100 do
  turtle.up()
  y = y + 1
end
while turtle.detectUp() do
  turtle.digUp()
  for i = 1, 4 do
    if turtle.detect() then turtle.dig() end
    turtle.turnLeft()
  end
  turtle.up()
  y = y + 1
end
for i = y, 0, -1 do
  turtle.down()
end
--region *.lua

local args = { ... }
if #args < 2 then
  print("Usage: treefarm <length> <width> [interval]")
  return
end

if not terp then
  os.loadAPI("/terp/lib/terp")
end

if not location then
  os.loadAPI("/terp/lib/location")
end

if not inventory then
  os.loadAPI("/terp/lib/inventory")
end

if not itemTypeCollection then
  os.loadAPI("/terp/lib/itemTypeCollection")
end

local function getOtherDirection(turn)
  return turn == terp.turnRight and terp.turnLeft or terp.turnRight
end

local function goAround()
  terp.turnRight()
  terp.forward()
  terp.turnLeft()
  terp.forward()
  terp.forward()
  terp.turnLeft()
  terp.forward()
  terp.turnRight()
end

local function selectSapling(detail)
  return detail and string.match(detail.name, "[sS]apling")
end

local function plant()
  terp.up()
  terp.placeItemDown(selectSapling, 1, 16)
  terp.forward()
  terp.down()
end

local function fell()
  terp.forward()
  while terp.detectUp() do
    terp.up()
  end
  while not terp.detectDown() do
    terp.down()
  end
  terp.forward()
end

local function processSite()
  local anything, current = terp.inspect()
  if not anything then
    terp.forward()
    plant()
  elseif selectSapling(current) then
    goAround()
  elseif current and (string.match(current.name, "[Ll]og") or string.match(current.name, "[Ww]ood")) then
    fell()
    plant()
  end
end

local length = tonumber(args[1])
local width = tonumber(args[2])
local spacing = args[3] and tonumber(args[3]) or 10
local turn = terp.turnRight
local origin = terp.getLocation()
if width < 0 then
  turn = terp.turnLeft
  width = width * -1
end
local halfSpace = math.floor(spacing / 2)

local function moveToNext()
  -- position is N + 1, next check point is N + spacing - 1
  -- so start with 2 already down
  for k = 3, spacing do
    terp.forward()
  end
end

while true do
  turn()
  for k = 1, halfSpace do
    terp.forward()
  end
  getOtherDirection(turn)()
  for k = 1, halfSpace do
    terp.forward()
  end
  for i = halfSpace + spacing, width, spacing do
    processSite()
    for j = halfSpace, length, spacing do
      moveToNext()
      processSite()
    end
    turn()
    for k = 1, spacing do
      terp.forward()
    end
    turn()
    turn = getOtherDirection(turn)
  end
  terp.moveTo(origin)
  terp.turnAround()
  for i = 1, 16 do
    if not selectSapling(terp.getItemDetail(i)) then
      terp.select(i)
      terp.drop()
    end
  end
  terp.turnAround()
  print("Waiting...")
  os.sleep(1800)
end

--endregion
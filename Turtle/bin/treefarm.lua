--region *.lua

if not terp then
  os.loadAPI("terp")
end

if not location then
  os.loadAPI("location")
end

if not itemTypeCollection then
  os.loadAPI("itemTypeCollection")
end



local function getOtherDirection(turn)
  return turn == terp.turnRight and terp.turnLeft or terp.turnRight
end

local args = { ... }
if #args < 2 then
  print("Usage: treefarm <length> <width> [interval]")
end

local length = tonumber(args[1])
local width = tonumber(args[2])
local spacing = args[3] and tonumber(args[3]) or 10
local turn = terp.turnRight
if width < 0 then
  turn = terp.turnLeft
  width = width * -1
end
local halfSpace = math.floor(spacing / 2)
local selectSapling =
  function(detail)
    return string.match(detail.name, "[sS]apling")
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
  for i = spacing, width, spacing do
    for j = spacing, length, spacing do
      local current = terp.inspect()
      if selectSapling(current) then
        terp.turnRight()
        terp.forward()
        terp.turnLeft()
        terp.forward()
        terp.turnLeft()
        terp.forward()
        terp.turnRight()
      elseif string.match(current.name, "[Ll]og") or string.match(current.name, "[Ww]ood") then
        terp.forward()
        while terp.detectUp() do
          terp.up()
        end
        while not terp.detectDown() do
          terp.down()
        end
        terp.forward()
      else
        terp.forward()
        terp.up()
        terp.placeItemDown(selectSapling, 1, 16)
        terp.forward()
        terp.down()
      end
    end
  end
  terp.moveTo(0, 0, 0)
  terp.turnAround()
  for i = 1, 16 do
    if not selectSapling(terp.getItemDetail(i)) then
      terp.select(i)
      terp.drop()
    end
  end
  print("Waiting...")
  os.sleep(1800)
end

--endregion

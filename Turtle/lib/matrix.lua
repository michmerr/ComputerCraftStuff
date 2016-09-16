-- region *.lua
-- Date
local matrixBase = { }
local mt = { __index = matrixBase }

function new(matrixArray)
  assert(matrixArray and type(matrixArray) == "table" and #matrixArray > 0, "an array of the matrix values must be passed to the constructor")
  if getmetatable(matrixArray) == mt then
    return matrixArray:clone()
  end
  return setmetatable(matrixArray, mt)
end

function matrixBase:multiply(m)

  assert(m, "matrix cannot be nil")
  assert(#m > 0, "matrix cannot be empty.")
  --print(#self)
  --print(tostring(self[1]))
  --print(#self[1])
  assert(#self > 0 and self[1], "comparing matrix must have at least one dimension: "..matrixBase.tostring(self))
  -- print("--------")
  -- print("Multiplying:")
  -- print(orientation.printMatrix(self))
  -- print(orientation.printMatrix(matrix))

  local result = { }
  local columnCount = #m[1]
  local rowCount = #m
  --print(self[1])
  assert(#self[1] == rowCount, "The second matrix must have the same number of rows as the first matrix has columns.")

  for productRow = 1, rowCount do
    result[productRow] = { }
    for productColumn = 1, columnCount do
      result[productRow][productColumn] = 0
      for i = 1, rowCount do
        -- print ("productRow = "..tostring(productColumn).." productColumn = "..tostring(productColumn).." i = "..tostring(i))
        result[productRow][productColumn] = result[productRow][productColumn] +(self[productRow][i] * m[i][productColumn])
      end
    end
  end

  -- print "Result:"
  -- print(orientation.printMatrix(result))

  return matrix.new(result)
end


function matrixBase:tostring()
  local max
  local min
  for i = 1, #self do
    max = max and math.max(max, table.unpack(self[i])) or table.unpack(self[i])
    min = min and math.min(min, table.unpack(self[i])) or table.unpack(self[i])
  end
  max = math.max(string.len(max or 0), string.len(min or 0))
  local formatString = "%" .. max .. "d"
  local result = ""
  for i = 1, #self do
    for j = 1, #self[i] do
      result = result .. string.format(formatString, self[i][j]) .. "  "
    end
    result = result .. "\n"
  end
  return result
end

function matrixBase:equals(m)
  if not m or type(m) ~= "table" or #m ~= #self then
    return false
  end

  for i = 1, #self do
    if not m[i] or type(m[i]) ~= "table" or #m[i] ~= #self[i] then
      return false
    end
    for j = 1, #self[i] do
      if m[i][j] ~= self[i][j] then
        return false
      end
    end
  end
  return true
end

function matrixBase:clone()
  local result = { }
  for i = 1, #self do
    local row = { }
    for j = 1, #self[i] do
      table.insert(row, self[i][j])
    end
    table.insert(result, row)
  end
  return new(result)
end

mt.__eq = matrixBase.equals
mt.__mul = matrixBase.multiply
mt.__tostring = matrixBase.tostring


-- endregion

-- region *.lua
-- Date
local matrixBase = { }
local mt = { __index = matrixBase }

function new(matrixArray)
  local self = matrixArray or { }
  return setmetatable(self, mt)
end

function matrixBase:multiply(m)

  assert(m, "matrix cannot be nil")
  assert(#m > 0, "matrix cannot be empty.")

  -- print("--------")
  -- print("Multiplying:")
  -- print(orientation.printMatrix(self))
  -- print(orientation.printMatrix(matrix))

  local result = { }
  local columnCount = #m[1]
  local rowCount = #m

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
  local max = self[1][1]
  local min = self[1][1]
  for i = 1, #self do
    max = math.max(max, table.unpack(self[i]))
    min = math.min(min, table.unpack(self[i]))
  end
  max = math.max(string.len(max), string.len(min))
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
  return result
end

mt.__eq = matrixBase.equals
mt.__mul = matrixBase.multiply
mt.__tostring = matrixBase.tostring


-- endregion

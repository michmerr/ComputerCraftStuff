--region *.lua

orientation = {}

function orientation.printMatrix(matrix)
    if not matrix then
        return "nil"
    end

    if type(matrix) == "table" then
        local result = "{ "
        for k,v in pairs(matrix) do
            result = result.."["..k.."] = "..orientation.printMatrix(v).."; "
        end
        return result.." };\n"
    else
        return tostring(matrix)
    end
end

function orientation.create(initialorientation)

    local attitude = initialorientation or {
            { 1; 0; 0 };
            { 0; 1; 0 };
            { 0; 0; 1 }
        }

    local self = {}

    local transforms = {
        ["yawRight"] = {
            { 0; 0; 1 };
            { 0; 1; 0 };
            { -1; 0; 0 }
        };
        ["yawLeft"] = {
            { 0; 0; -1 };
            { 0; 1; 0 };
            { 1; 0; 0 }
        };
        ["pitchUp"] = {
            { 1; 0; 0 };
            { 0; 0; 1 };
            { 0; -1; 0 }
        };
        ["pitchDown"] = {
            { 1; 0; 0 };
            { 0; 0; -1 };
            { 0; 1; 0 }
        };
        ["rollRight"] = {
            { 0; 1; 0 };
            { -1; 0; 0 };
            { 0; 0; 1 }
        };
        ["rollLeft"] = {
            { 0; -1; 0 };
            { 1; 0; 0 };
            { 0; 0; 1 }
        };
    }

    -- The definitions are based on a vertical Y axis, and a Z axis in the same plane as the X.
    local translations = {
        ["forward"] = { { 0 }; { 0 }; { 1 } };
        ["back"] = { { 0 }; { 0 }; { -1 } };
        ["left"] = { { -1 }; { 0 }; { 0 } };
        ["right"] = { { 1 }; { 0 }; { 0 } };
        ["up"] = { { 0 }; { 1 }; { 0 } };
        ["down"] = { { 0 }; { -1 }; { 0 } }
    }

    local function multiply(matrixA, matrixB)

        assert(matrixA, "matrixA cannot be nil")
        assert(matrixB, "matrixB cannot be nil")
        assert(#matrixB > 0, "matrixB cannot be empty.")

        -- print("--------")
        -- print("Multiplying:")
        -- print(orientation.printMatrix(matrixA))
        -- print(orientation.printMatrix(matrixB))

        local result = { }
        local columnCount = #matrixB[1]
        local rowCount = #matrixB

        assert(#matrixA[1] == rowCount, "The second matrix must have the same number of rows as the first matrix has columns.")

        for r = 1, rowCount do
            result[r] = { }
            for c = 1, columnCount do
                result[r][c] = 0
                for i = 1, rowCount do
                    -- print ("r = "..tostring(r).." c = "..tostring(c).." i = "..tostring(i))
                    result[r][c] = result[r][c] + (matrixA[r][i] * matrixB[i][c])
                end
            end
        end

        -- print "Result:"
        -- print(orientation.printMatrix(result))

        return result
    end

    function self.yawRight()
        attitude = multiply(attitude, transforms.yawRight)
    end

    function self.yawLeft()
        attitude = multiply(attitude, transforms.yawLeft)
    end

    function self.pitchUp()
        attitude = multiply(attitude, transforms.pitchUp)
    end

    function self.pitchDown()
        attitude = multiply(attitude, transforms.pitchDown)
    end

    function self.rollRight()
        attitude = multiply(attitude, transforms.rollRight)
    end

    function self.rollLeft()
        attitude = multiply(attitude, transforms.rollLeft)
    end

    local function translate(translation)
        local result = multiply(attitude, translation)
        return { result[1][1]; result[2][1]; result[3][1] }
    end

    function self.translateForward()
        return translate(translations.forward);
    end

    function self.translateBackward()
        return translate(translations.back);
    end

    function self.translateUp()
        return translate(translations.up);
    end

    function self.translateDown()
        return translate(translations.down);
    end

    function self.translateLeft()
        return translate(translations.left);
    end

    function self.translateRight()
        return translate(translations.right);
    end

    return self;
end
--endregion

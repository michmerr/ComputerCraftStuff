-- region *.lua

if require then
  require("matrix")
else
  os.loadAPI("/terp/lib/matrix")
end


-- The definitions are based on a vertical Y axis, and a Z axis in the same plane as the X.
translations = {
  ["forward"] = matrix.new( { { 0 }; { 0 }; { 1 } });
  ["back"] = matrix.new( { { 0 }; { 0 }; { - 1 } });
  ["left"] = matrix.new( { { - 1 }; { 0 }; { 0 } });
  ["right"] = matrix.new( { { 1 }; { 0 }; { 0 } });
  ["up"] = matrix.new( { { 0 }; { 1 }; { 0 } });
  ["down"] = matrix.new( { { 0 }; { - 1 }; { 0 } })
}

transforms = {
  ["neutral"] = matrix.new( {
    { 1; 0; 0 };
    { 0; 1; 0 };
    { 0; 0; 1 }
  } );
  ["yawRight"] = matrix.new( {
    { 0; 0; 1 };
    { 0; 1; 0 };
    { - 1; 0; 0 }
  } );
  ["yawLeft"] = matrix.new( {
    { 0; 0; -1 };
    { 0; 1; 0 };
    { 1; 0; 0 }
  } );
  ["pitchUp"] = matrix.new( {
    { 1; 0; 0 };
    { 0; 0; 1 };
    { 0; -1; 0 }
  } );
  ["pitchDown"] = matrix.new( {
    { 1; 0; 0 };
    { 0; 0; -1 };
    { 0; 1; 0 }
  } );
  ["rollRight"] = matrix.new( {
    { 0; 1; 0 };
    { - 1; 0; 0 };
    { 0; 0; 1 }
  } );
  ["rollLeft"] = matrix.new( {
    { 0; -1; 0 };
    { 1; 0; 0 };
    { 0; 0; 1 }
  } );
}

transforms.reverseYaw = transforms.yawLeft * transforms.yawLeft
transforms.reversePitch = transforms.pitchDown * transforms.pitchDown
transforms.reverseRoll = transforms.rollLeft * transforms.rollLeft

function translate(from, to)
  print("translate")
  local result = from * to
  return result[1][1], result[2][1], result[3][1]
end

function getRelative(fromOrientation, directionTransform)
  directionTransform = directionTransform or transforms.neutral
  return fromOrientation * directionTransform
end

function create(state)

  local attitude = matrix.new(state or transforms.neutral)

  local self = { }

  function self.getState()
    return attitude:clone()
  end

  function self.yawRight()
    attitude = attitude * transforms.yawRight
  end

  function self.yawLeft()
    attitude = attitude * transforms.yawLeft
  end

  function self.pitchUp()
    attitude = attitude * transforms.pitchUp
  end

  function self.pitchDown()
    attitude = attitude * transforms.pitchDown
  end

  function self.rollRight()
    attitude = attitude * transforms.rollRight
  end

  function self.rollLeft()
    attitude = attitude * transforms.rollLeft
  end

  local function translate(translation)
    local result = attitude * translation
    return result[1][1], result[2][1], result[3][1]
  end

  function self.translateForward()
    return translate(translations.forward)
  end

  -- Get vector components for a facing. If no direction is provided, forward is assumed.
  function self.getFacing(translateDirection)
    return orientation.getRelative(attitude, translateDirection)
  end

  function self.translateBackward()
    return translate(translations.back)
  end

  function self.translateUp()
    return translate(translations.up)
  end

  function self.translateDown()
    return translate(translations.down)
  end

  function self.translateLeft()
    return translate(translations.left)
  end

  function self.translateRight()
    return translate(translations.right)
  end

  return self;
end
-- endregion

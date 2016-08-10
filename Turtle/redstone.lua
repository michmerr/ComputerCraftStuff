if not redstone then
  redstone = {}
end
if not redstone.getSides then
  function redstone.getSides( )
    return { }
  end
end

if not redstone.setOutput then
  function redstone.setOutput( arg0, arg1 )
  end
end

if not redstone.getOutput then
  function redstone.getOutput( arg0 )
  end
end

if not redstone.getInput then
  function redstone.getInput( arg0 )
  end
end

if not redstone.setBundledOutput then
  function redstone.setBundledOutput( arg0, arg1 )
  end
end

if not redstone.getBundledOutput then
  function redstone.getBundledOutput( arg0 )
  end
end

if not redstone.getBundledInput then
  function redstone.getBundledInput( arg0 )
  end
end

if not redstone.testBundledInput then
  function redstone.testBundledInput( arg0, arg1 )
    return true
  end
end

if not redstone.setAnalogOutput then
  function redstone.setAnalogOutput( arg0, arg1 )
  end
end

if not redstone.setAnalogueOutput then
  function redstone.setAnalogueOutput( arg0, arg1 )
  end
end

if not redstone.getAnalogOutput then
  function redstone.getAnalogOutput( arg0 )
    return 1
  end
end

if not redstone.getAnalogueOutput then
  function redstone.getAnalogueOutput( arg0 )
    return 1
  end
end

if not redstone.getAnalogInput then
  function redstone.getAnalogInput( arg0 )
    return 1
  end
end

if not redstone.getAnalogueInput then
  function redstone.getAnalogueInput( arg0 )
    return 1
  end
end

return redstone

if not rs then
  rs = {}
end
if not rs.getSides then
  function rs.getSides( )
    return { }
  end
end

if not rs.setOutput then
  function rs.setOutput( arg0, arg1 )
  end
end

if not rs.getOutput then
  function rs.getOutput( arg0 )
  end
end

if not rs.getInput then
  function rs.getInput( arg0 )
  end
end

if not rs.setBundledOutput then
  function rs.setBundledOutput( arg0, arg1 )
  end
end

if not rs.getBundledOutput then
  function rs.getBundledOutput( arg0 )
  end
end

if not rs.getBundledInput then
  function rs.getBundledInput( arg0 )
  end
end

if not rs.testBundledInput then
  function rs.testBundledInput( arg0, arg1 )
    return true
  end
end

if not rs.setAnalogOutput then
  function rs.setAnalogOutput( arg0, arg1 )
  end
end

if not rs.setAnalogueOutput then
  function rs.setAnalogueOutput( arg0, arg1 )
  end
end

if not rs.getAnalogOutput then
  function rs.getAnalogOutput( arg0 )
    return 1
  end
end

if not rs.getAnalogueOutput then
  function rs.getAnalogueOutput( arg0 )
    return 1
  end
end

if not rs.getAnalogInput then
  function rs.getAnalogInput( arg0 )
    return 1
  end
end

if not rs.getAnalogueInput then
  function rs.getAnalogueInput( arg0 )
    return 1
  end
end

return rs

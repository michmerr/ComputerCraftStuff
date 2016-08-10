if not peripheral then
  peripheral = {}
end
if not peripheral.isPresent then
  function peripheral.isPresent( )
    return true
  end
end

if not peripheral.getType then
  function peripheral.getType( )
    return ""
  end
end

if not peripheral.getMethods then
  function peripheral.getMethods( )
    return { }
  end
end

if not peripheral.call then
  function peripheral.call( arg0 )
    return true
  end
end

return peripheral

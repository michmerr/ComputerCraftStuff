if not os then
  os = {}
end
if not os.queueEvent then
  function os.queueEvent( arg0, arg1 )
  end
end

if not os.startTimer then
  function os.startTimer( arg0 )
    return 1
  end
end

if not os.setAlarm then
  function os.setAlarm( arg0 )
    return 1
  end
end

if not os.shutdown then
  function os.shutdown( )
  end
end

if not os.reboot then
  function os.reboot( )
  end
end

if not os.computerID then
  function os.computerID( )
    return 1
  end
end

if not os.getComputerID then
  function os.getComputerID( )
  end
end

if not os.setComputerLabel then
  function os.setComputerLabel( arg0 )
  end
end

if not os.computerLabel then
  function os.computerLabel( )
    return ""
  end
end

if not os.getComputerLabel then
  function os.getComputerLabel( )
    return ""
  end
end

if not os.clock then
  function os.clock( )
    return 1
  end
end

if not os.time then
  function os.time( )
    return 1
  end
end

if not os.day then
  function os.day( )
    return 1
  end
end

if not os.cancelTimer then
  function os.cancelTimer( arg0 )
  end
end

if not os.cancelAlarm then
  function os.cancelAlarm( arg0 )
  end
end

if not os.sleep then
    function os.sleep( nTime )
    end
end

if not os.loadAPI then
    function os.loadAPI( apiName )
    end
end
return os

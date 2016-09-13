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
    function os.loadAPI( _sPath )
      local sName = fs.getName( _sPath )
      if string.sub(_sPath, -4) ~= ".lua" then
        _sPath = _sPath..".lua"
      end
      local tEnv = {}
      setmetatable( tEnv, { __index = _G } )
      local fnAPI, err = loadfile(_sPath, tEnv )
      if fnAPI then
          local ok, err = pcall( fnAPI )
          if not ok then
              print("ERROR:"..err.." (".._sPath..")")
              return false
          end
      else
          print("ERROR:".. err.." (".._sPath..")" )
          return false
      end

      local tAPI = {}
      for k,v in pairs( tEnv ) do
          if k ~= "_ENV" then
              tAPI[k] =  v
          end
      end

      _G[sName] = tAPI
      return true
  end
end

if not os.unloadAPI then
  function os.unloadAPI( _sName )
      if _sName ~= "_G" and type(_G[_sName]) == "table" then
          _G[_sName] = nil
      end
  end
end
return os

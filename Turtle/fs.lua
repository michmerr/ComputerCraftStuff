if not fs then
  fs = {}
end
if not fs.list then
  function fs.list( arg0 )
    return { }
  end
end

if not fs.combine then
  function fs.combine( arg0, arg1 )
    return ""
  end
end

if not fs.getName then
  function fs.getName( arg0 )
    return ""
  end
end

if not fs.getSize then
  function fs.getSize( arg0 )
  end
end

if not fs.exists then
  function fs.exists( arg0 )
    return true
  end
end

if not fs.isDir then
  function fs.isDir( arg0 )
    return true
  end
end

if not fs.isReadOnly then
  function fs.isReadOnly( arg0 )
    return true
  end
end

if not fs.makeDir then
  function fs.makeDir( arg0 )
  end
end

if not fs.move then
  function fs.move( arg0, arg1 )
  end
end

if not fs.copy then
  function fs.copy( arg0, arg1 )
  end
end

if not fs.delete then
  function fs.delete( arg0 )
  end
end

if not fs.open then
  function fs.open( arg0 )
    return 1
  end
end

if not fs.getDrive then
  function fs.getDrive( arg0 )
    return ""
  end
end

if not fs.getFreeSpace then
  function fs.getFreeSpace( arg0 )
  end
end

if not fs.find then
  function fs.find( arg0 )
    return { }
  end
end

if not fs.getDir then
  function fs.getDir( arg0 )
    return ""
  end
end

return fs

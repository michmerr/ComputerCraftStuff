if not utilities then
  dofile("../lib/utilities.lua")
end
if not fs then
  fs = {}
end
if not fs.list then
  function fs.list( arg0 )
    local result = os.execute('dir /b '..string.gsub(arg0, "/", "\\"))
    return string.gsub(result, "\\", "/")
  end
end

if not fs.combine then
  function fs.combine( arg0, arg1 )
    arg0 = string.sub(arg0, -1) ~= "/" and arg0 or string.sub(arg0, 1, -1)
    arg0 = string.sub(arg1, 1, 1) ~= "/" and arg0 or string.sub(arg0, 2)
    return arg0.."/"..arg1
  end
end

if not fs.getName then
  function fs.getName( arg0 )
    -- print(arg0)
    local tokens = string.split(arg0, "/")
    return string.sub(tokens[#tokens], 1, (string.find(tokens[#tokens], ".", 1, "plain") or 0) - 1)
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
    return false
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
  function fs.open(file, mode)
    return io.open(file, mode)
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
    cmd = 'dir /b/a-d '..string.gsub(arg0, "/", "\\")
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()
    return string.split(string.gsub(s, "\\", "/"),"\n", true)
  end
end

if not fs.getDir then
  function fs.getDir( arg0 )
    return ""
  end
end

local nativesetfenv = setfenv
local nativegetfenv = getfenv
if _VERSION == "Lua 5.1" then
    -- Install parts of the Lua 5.2 API so that programs can be written against it now
    local nativeload = load
    local nativeloadstring = loadstring
    function load( x, name, mode, env )
        if mode ~= nil and mode ~= "t" then
            error( "Binary chunk loading prohibited", 2 )
        end
        local ok, p1, p2 = pcall( function()
            if type(x) == "string" then
                local result, err = nativeloadstring( x, name )
                if result then
                    if env then
                        env._ENV = env
                        nativesetfenv( result, env )
                    end
                    return result
                else
                    return nil, err
                end
            else
                local result, err = nativeload( x, name )
                if result then
                    if env then
                        env._ENV = env
                        nativesetfenv( result, env )
                    end
                    return result
                else
                    return nil, err
                end
            end
        end )
        if ok then
            return p1, p2
        else
            error( p1, 2 )
        end
    end
    table.unpack = unpack
    table.pack = function( ... ) return { ... } end

    if _CC_DISABLE_LUA51_FEATURES then
        -- Remove the Lua 5.1 features that will be removed when we update to Lua 5.2, for compatibility testing.
        -- See "disable_lua51_functions" in ComputerCraft.cfg
        setfenv = nil
        getfenv = nil
        loadstring = nil
        unpack = nil
        math.log10 = nil
        table.maxn = nil
        bit = nil
    end
end

loadfile = function( _sFile, _tEnv )
  if string.sub(_sFile, 1, 5) == "/terp" then
    _sFile = string.sub(_sFile, 6)
  end
  local file = fs.open( _sFile, "r" )
  if not file then
    local searchPath = string.split(package.path, ";", true)
    for i = 1, #searchPath do
      local path = string.gsub(searchPath[i], '?', _sFile)
      --print("trying: "..path)
      file = fs.open(path, "r")
      if file then
      --print("opened "..path)
        break
      end
    end
  end
  if file then
      local func, err = load( file:read("*a"), fs.getName( _sFile ), "t", _tEnv )
      file:close()
      return func, err
  end
  return nil, "File not found"
end
return fs

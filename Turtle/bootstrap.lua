-- region *.lua
-- Date
local githubUrl = "https://raw.githubusercontent.com/michmerr/ComputerCraftStuff/master/Turtle"
local manifest = "bootstrap_manifest"
local bootstrapper = "_bootstrap"
local bootstrapDir = "/.bootstrap"
local bootstrapperPath = bootstrapDir.."/"..bootstrapper
local manifestPath = bootstrapDir.."/"..manifest

-- grafting in wget code, since CC under MC 1.7.10 doesn't have it in the ROM, and this is the bootstrapper...
local function get( sUrl )
    local ok, err = http.checkURL( sUrl )
    if not ok then
        write( "Invalid url" )
        if err then
            print( ": "..err )
        end
        return nil
    end

    local response = http.get( sUrl )
    if not response then
        print( "Get failed for "..tostring(sUrl) )
        return nil
    end

    local sResponse = response.readAll()
    response.close()
    return sResponse
end

local function wget(sUrl, sFile)
  local sPath = shell.resolve(sFile)
  if fs.exists(sPath) then
    if fs.isDir(sPath) then
      print("Local filepath points to an existing DIRECTORY.")
      return nil
    end
    fs.delete(sPath)
  elseif not fs.exists(fs.getDir(sPath)) then
    fs.makeDir(fs.getDir(sPath))
  end

  -- Do the get
  local res = get(sUrl)
  if res then
      local file = fs.open( sPath, "w" )
      file.write(res)
      file.close()
      return true
  end
  return nil
end

local function updateFile(from, to)
  write(string.format("Updating %s ...", to))
  if wget(githubUrl.."/"..from, to) then
    print("ok")
    return true
  else
    print("failed")
    return nil
  end
end

local function cleanMovedFiles(oldFiles, currentFiles)
  for i = 1, #oldFiles do
    if fs.exists(oldFiles[i].localPath) then
      local found = false
      for j = 1, #currentFiles do
        if oldFiles[i].localPath == currentFiles[i].localPath then
          found = true
          break;
        end
      end
      if not found then
        print("removing "..oldFiles[i].localPath)
        fs.delete(oldFiles[i].localPath)
      end
    end
  end
end

local function parseManifestLine(line)
  local _, _, source, localRoot = string.find(line, "%s*(.+)%s*,%s*(.+)%s*")
  local localPath = string.gsub(localRoot.."/"..source, "//+", "/")
  local fileUrl = githubUrl.."/"..source..".lua"
  return fileUrl, localPath
end

local function readManifest(filename)
  local result = { }
  hFile = assert(fs.open(filename, "r"))
  while hFile do
    local line = hFile.readLine()
    if not line then
      hFile.close()
      break;
    end
    local serverPath, localPath = parseManifestLine(line)
    table.insert(result, { serverPath = serverPath; localPath = localPath; })
  end
  return result
end

local function updateManifest()
  local oldManifest
  local existingFiles
  if fs.exists(manifestPath) then
    oldManifest = manifestPath..".old"
    if fs.exists(oldManifest) then
      delete(oldManifest)
    end
    fs.copy(manifestPath, oldManifest)
  end
  if not updateFile(manifest, manifestPath) then
    if fs.exists(manifestPath) then
      delete(manifestPath)
    end
    if oldManifest then
      fs.move(oldManifest, manifestPath)
    end
    return nil
  end
  if oldManifest then
    existingFiles = readManifest(oldManifest)
    delete(oldManifest)
  end
  return true, existingFiles
end

local function pull()
  local pass = 0
  local fail = 0

  local success, existingFiles = updateManifest(existingFiles)
  if not success then
    print "Failed to retrieve manifest. Aborting."
    return false
  end
  local filelist = readManifest(manifestPath)
  for i = 1, #filelist do
    write(filelist[i].localPath.."...")
    if updateFile(filelist[i].serverPath, filelist[i].localPath) then
      pass = pass + 1
    else
      fail = fail + 1
    end
  end
  if existingFiles then
    cleanMovedFiles(existingFiles, filelist)
  end

  print(string.format("Files updated successfully: %d", pass))
  if (fail > 0) then
    print(string.format("File updates failed: %d", fail))
  end

end

local args = { ...}

if args[1] and args[1] == "exec" then
  pull()
else
  if updateFile(fs.getName(shell.getRunningProgram())..".lua", bootstrapperPath) then
    print("Executing updated bootstrapper...")
    shell.run(bootstrapperPath, "exec")
  else
    print("Aborting bootstrapper.")
  end
end
-- endregion

--region *.lua
--Date

if not LogListener then
  os.loadAPI("/terp/lib/LogListener")
end

function new(filename, threshold, specificLevels, append)
  local self = LogListener.create(threshold, specificLevels)
  local file

  local function openLogFile()
    if not append and fs.exists(filename) then
      fs.delete(filename)
    end
    file = io.open(filename, append and "a" or "w")
  end

  function self.log(level, pattern, ...)
    if not file then
      openLogFile()
    end
    if not self.shouldLog(level) then
      return
    end
    local patternValues = { ... }
        if #patternValues > 0 then
      file:write(string.format(pattern.."\n", ...))
    else
      file:write(pattern.."\n")
    end
    file:flush()
  end

  function self.dispose()
    if file then
      file.flush()
      file.close()
    end
  end

  return self
end



--endregion

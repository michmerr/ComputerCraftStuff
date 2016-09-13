--region *.lua
--Date
if not LogListener then
  os.loadAPI("/terp/LogListener")
end

function new(threshold, specificLevels)
  local self = LogListener.create(threshold, specificLevels)

  function self.log(level, pattern, ...)
    if not self.shouldLog(level) then
      return
    end
    local patternValues = { ... }
        if #patternValues > 0 then
      print(string.format(pattern, ...))
    else
      print(pattern)
    end
  end

  return self
end


--endregion

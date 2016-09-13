--region *.lua
--Date

if not bit then
  os.loadAPI("../rom/apis/bit")
end
if not Logger then
  os.loadAPI("/terp/Logger")
end

function create(threshold, specificLevels)
  local self = {
    threshold = Logger.levels.DEFAULT;
    specificLevels = 0x00
  }
  if threshold then
    self.threshold = threshold
  end

  if specificLevels then
    self.specificLevels = specificLevels
  end

  function self.shouldLog(level)
    return self.threshold <= level or bit.band(self.specificLevels, level) == level
  end

  function self.log(level, pattern, ...)
    assert(false, "abstract method; must be implemented by deriving class")
  end

  return self
end


--endregion

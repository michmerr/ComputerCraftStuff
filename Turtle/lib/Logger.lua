--region *.lua
--Date

levels = {
  FATAL_ERROR = 0x20;
  ERROR = 0x10;
  MESSAGE = 0x08;
  DEFAULT = 0x08;
  WARNING = 0x04;
  INFO = 0x02;
  DEBUG = 0x01
  }

local logger = {
  listeners = { }
}

local mt = { __index = logger }

function new(o)
  local self = o or { }
  return setmetatable(self, mt)
end

function logger:log(...)
  for i = 1, #self.listeners do
    self.listeners[i].log(...)
  end
end

local globalLogger
function setGlobalLogger(gLogger)
  globalLogger = gLogger
end

function log(level, pattern, ...)
  if globalLogger then
    globalLogger:log(level, pattern, ...)
  end
end




--endregion

--region *.lua
local p = shell.path()
p = p..":".."/terp/lib"
p = p..":".."/terp/bin"
shell.setPath(p)
--endregion

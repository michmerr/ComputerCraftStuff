if not buffer then
  buffer = {}
end
if not buffer.new then
  function buffer.new( arg0, arg1 )
    return 1
  end
end

return buffer

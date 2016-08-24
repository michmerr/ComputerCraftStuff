if not term then
  term = {}
end
if not term.write then
  function term.write( arg0 )
  end
end

if not term.scroll then
  function term.scroll( arg0 )
  end
end

if not term.setCursorPos then
  function term.setCursorPos( arg0, arg1 )
  end
end

if not term.setCursorBlink then
  function term.setCursorBlink( arg0 )
  end
end

if not term.getCursorPos then
  function term.getCursorPos(if not term.getSize then
  function term.getSize(if not term.clear then
  function term.clear( )
  end
end

if not term.clearLine then
  function term.clearLine( )
  end
end

if not term.setTextColour then
  function term.setTextColour( arg0 )
  end
end

if not term.setTextColor then
  function term.setTextColor(if not term.setBackgroundColour then
  function term.setBackgroundColour( arg0 )
  end
end

if not term.setBackgroundColor then
  function term.setBackgroundColor(if not term.isColour then
  function term.isColour(if not term.isColor then
  function term.isColor(if not term.getTextColour then
  function term.getTextColour( )
  end
end

if not term.getTextColor then
  function term.getTextColor(if not term.getBackgroundColour then
  function term.getBackgroundColour( )
  end
end

if not term.getBackgroundColor then
  function term.getBackgroundColor(if not term.blit then
  function term.blit( arg0, arg1, arg2 )
  end
end

return term

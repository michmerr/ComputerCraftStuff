if not bit then
  bit = {}
end
if not bit.bnot then
  function bit.bnot( arg0 )
    return true
  end
end

if not bit.band then
  function bit.band( arg0, arg1 )
    return 1
  end
end

if not bit.bor then
  function bit.bor( arg0, arg1 )
    return 1
  end
end

if not bit.bxor then
  function bit.bxor( arg0, arg1 )
    return 1
  end
end

if not bit.brshift then
  function bit.brshift( arg0, arg1 )
    return 1
  end
end

if not bit.blshift then
  function bit.blshift( arg0, arg1 )
    return 1
  end
end

if not bit.blogic_rshift then
  function bit.blogic_rshift( arg0, arg1 )
    return 1
  end
end

return bit

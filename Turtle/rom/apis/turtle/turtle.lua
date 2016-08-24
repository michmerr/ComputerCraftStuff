if not turtle then
  turtle = {}
end
if not turtle.forward then
  function turtle.forward( )
    return true
  end
end

if not turtle.back then
  function turtle.back( )
    return true
  end
end

if not turtle.up then
  function turtle.up( )
    return true
  end
end

if not turtle.down then
  function turtle.down( )
    return true
  end
end

if not turtle.turnLeft then
  function turtle.turnLeft( )
    return true
  end
end

if not turtle.turnRight then
  function turtle.turnRight( )
    return true
  end
end

if not turtle.dig then
  function turtle.dig( )
    return true
  end
end

if not turtle.digUp then
  function turtle.digUp( )
    return true
  end
end

if not turtle.digDown then
  function turtle.digDown( )
    return true
  end
end

if not turtle.place then
  function turtle.place( arg0 )
    return true
  end
end

if not turtle.placeUp then
  function turtle.placeUp( )
    return true
  end
end

if not turtle.placeDown then
  function turtle.placeDown( )
    return true
  end
end

if not turtle.drop then
  function turtle.drop( arg0 )
    return true
  end
end

if not turtle.select then
  function turtle.select( arg0 )
    return true
  end
end

if not turtle.getItemCount then
  function turtle.getItemCount( arg0 )
  end
end

if not turtle.getItemSpace then
  function turtle.getItemSpace( arg0 )
  end
end

if not turtle.detect then
  function turtle.detect( )
    return true
  end
end

if not turtle.detectUp then
  function turtle.detectUp( )
    return true
  end
end

if not turtle.detectDown then
  function turtle.detectDown( )
    return true
  end
end

if not turtle.compare then
  function turtle.compare( )
    return true
  end
end

if not turtle.compareUp then
  function turtle.compareUp( )
    return true
  end
end

if not turtle.compareDown then
  function turtle.compareDown( )
    return true
  end
end

if not turtle.attack then
  function turtle.attack( )
    return true
  end
end

if not turtle.attackUp then
  function turtle.attackUp( )
    return true
  end
end

if not turtle.attackDown then
  function turtle.attackDown( )
    return true
  end
end

if not turtle.dropUp then
  function turtle.dropUp( arg0 )
    return true
  end
end

if not turtle.dropDown then
  function turtle.dropDown( arg0 )
    return true
  end
end

if not turtle.suck then
  function turtle.suck( )
    return true
  end
end

if not turtle.suckUp then
  function turtle.suckUp( )
    return true
  end
end

if not turtle.suckDown then
  function turtle.suckDown( )
    return true
  end
end

if not turtle.getFuelLevel then
  function turtle.getFuelLevel( )
  end
end

if not turtle.refuel then
  function turtle.refuel( )
    return true
  end
end

if not turtle.compareTo then
  function turtle.compareTo( arg0 )
    return true
  end
end

if not turtle.transferTo then
  function turtle.transferTo( arg0, arg1 )
    return true
  end
end

if not turtle.getSelectedSlot then
  function turtle.getSelectedSlot( )
  end
end

if not turtle.getFuelLimit then
  function turtle.getFuelLimit( )
  end
end

if not turtle.equipLeft then
  function turtle.equipLeft( )
    return true
  end
end

if not turtle.equipRight then
  function turtle.equipRight( )
    return true
  end
end

if not turtle.inspect then
  function turtle.inspect( )
    return true
  end
end

if not turtle.inspectUp then
  function turtle.inspectUp( )
    return true
  end
end

if not turtle.inspectDown then
  function turtle.inspectDown( )
    return true
  end
end

if not turtle.getItemDetail then
  function turtle.getItemDetail( arg0 )
  end
end

return turtle

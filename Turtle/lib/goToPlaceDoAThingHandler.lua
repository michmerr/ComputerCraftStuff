--region *.lua
os.loadAPI("terp")
os.loadAPI("waypointCollection")

function create(place, fromWaypoint, aThing)
  local self = { }
  local placeWaypoint = place
  local viaWaypoint = fromWaypoint
  local doAThing = aThing

  function self.getUnloadPoint()
    return placeWaypoint
  end
  
  function self.setPlace(waypoint, fromWaypoint)
    --TODO add checking/conversion for waypoint
    placeWaypoint = waypoint
  end

  function self.getRouteViaWaypoint()
    return placeWaypoint
  end

  function self.setRouteViaWaypoint(fromWaypoint)  
    viaWaypoint = fromWaypoint
  end
  
  function self.getAThing()
    return doAThing
  end

  function self.setAThing(func)  
    assert(func and type(func) == "function", "Expected a function")
    doAThing = func
  end

  function self.goToPlace()
    if viaWaypoint then
      if not terp.moveTo(viaWaypoint) then
        return false
      end
    end
    return terp.moveTo(placeWaypoint) 
  end

  -- unloading handler interface function
  function self.go()
    local returnPoint = terp.getLocation()
    local lastWaypoint = terp.getLastWaypoint()
    if not self.goToPlace() then
      return false
    end
    if not doAThing() then
      return false
    end
    return terp.moveTo(returnPoint)
  end

  return self
end


--endregion

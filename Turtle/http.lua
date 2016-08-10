if not http then
  http = {}
end
if not http.request then
  function http.request( arg0 )
    return true
  end
end

if not http.checkURL then
  function http.checkURL( arg0 )
    return true
  end
end

return http

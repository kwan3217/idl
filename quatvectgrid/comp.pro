;Component magnitude of vector u in the direction of vector b
function comp,u,b
  return,dotp(u,b)/vlength(b)
end

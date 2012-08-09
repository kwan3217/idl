;Orthogonal projection of vector u onto vector b, or vector component of
;u in the direction of b
function proj,u,b
  return,comp(u,b)*b/norm(b)
end
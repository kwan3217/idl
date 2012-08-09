;Orthogonal projection of vector u onto vector b, or vector component of
;u in the direction of b
function proj_p,u,b
  return,u-proj(u,b)
end
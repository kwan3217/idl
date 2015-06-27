;Function returns the angle between two vectors in radians.
function vangle,a,b
  aa=normalize_grid(a)
  bb=normalize_grid(b)
  dp=dotp(aa,bb)
  
  return,acos(dp)
end

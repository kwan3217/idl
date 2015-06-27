function dotp,a,b
  resolve_grid,a,x=ax,y=ay,z=az,w=aw
  resolve_grid,b,x=bx,y=by,z=bz,w=bw
  result=ax*bx
  result+=ay*by
  result+=az*bz
  if n_elements(aw) gt 0 then result+=aw*bw
  return,result
end

function normalize_grid,v
  resolve_grid,v,x=x,y=y,z=z
  len=vlength(v);
  result=compose_grid(x/len,y/len,z/len)
  return,result;
end
function vlength,v
  resolve_grid,v,x=x,y=y,z=z
  lensq=x^2+y^2+z^2;
  len=sqrt(lensq);
  return,len;
end
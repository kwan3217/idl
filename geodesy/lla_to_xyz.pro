function lla_to_xyz,lat=phi,lon=lon,alt=h,a=a,flat=flat
  if n_elements(a) eq 0 then a=6378137d
  if n_elements(flat) eq 0 then flat=1/298.257223563d;
  b=a*(1d -flat)
  psi=atan(b*tan(phi)/a)
  r=a*cos(psi)+h*cos(phi)
  z=b*sin(psi)+h*sin(phi)
  
  ;secondary method
  ;e2=(a^2-b^2)/a^2
  ;N=a/sqrt(1-e2*sin(phi)^2)
  ;r_=(N+h)*cos(phi)
  ;z_=(N*(1d -e2)+h)*sin(phi)
  ;stop
  
  x=r*cos(lon)
  y=r*sin(lon)
  return,compose_grid(x,y,z)
end
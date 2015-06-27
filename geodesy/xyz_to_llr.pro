function xyz_to_llr,vec, sid=sid, a=a, flat=flat
;xyz_to_llr Converts position vector to coordinates geocentric latitude,
;   longitude, and distance from center. This differs from xyz_to_lla, since
;   that calculates geodetic latitude and altitude above ellipsoid.
;

  resolve_grid,vec,x=x,y=y,z=z
  if n_elements(sid) eq 0 then sid=0
  lon=constrain(atan(y,x)-sid,2*!dpi);
  rho=sqrt(x*x+y*y);
  r=sqrt(x*x+y*y+z*z);
  lat=atan(z/rho);

  return,compose_grid(lat,lon,r)
end
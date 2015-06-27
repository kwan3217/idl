function twobody_grav,ri_
  ri=ri_/1000d; internally we work in km, interface is in m
  rb=3397d
  mu=4.2828371901284001d+04; 42828.371901(73)
  cbar20=-8.7450547081842009d-04
  n=-mu/vlength(ri)^3
  return,ri*compose_grid(n,n,n)*1000d; Convert back to m
end

function n_lm,l,m
  if m eq 0 then delta=1 else delta=0
  return,sqrt((2-delta)*(2*l+1)*factorial(l-m)/factorial(l+m))
end

function cbar20_grav,ri_
  ri=ri_/1000d; internally we work in km, interface is in m
  rb=3397d ;It doesn't matter what the ellipsoid is, use this value for this J2
  mu=4.2828371901284001d+04; 42828.371901(73)
  cbar20=-8.7450547081842009d-04
  c20=cbar20/n_lm(2,0)
  r=vlength(ri)
  resolve_grid,ri,x=x,y=y,z=z
  coef=3d*c20*mu*rb^2d/(2d*r^5d)
  ax=coef*x*(1d -5d*z^2d/r^2d)
  ay=coef*y*(1d -5d*z^2d/r^2d)
  az=coef*z*(3d -5d*z^2d/r^2d)
  return,compose_grid(ax,ay,az)*1000d
end

;Calculate various mars environment parameters based on aerocentric relative vector in IAU_MARS frame
;Input
;  r_rel - Aerocentric relative position vector, in Mars-co-rotating IAU_MARS frame, in meters
;return
;  acceleration of gravity in m/s^2 at this point, including central body and J2, in IAU_MARS frame
function marsgrav,r_rel
  return,twobody_grav(r_rel)+cbar20_grav(r_rel)
end
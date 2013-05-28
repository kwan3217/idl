;Given state vector, calculate orbital elements
;input
;  r - position vector, may be a grid of vectors, in distance units implied by mu, any inertial frame is fine, but center of attraction is assumed to be
;      at the origin of the frame
;  v - inertial velocity vector, must follow r as either not a grid or a grid of the same size, distance and time units implied by mu
;      must be in same frame as r
;  l_du - length of a distance unit, used for conversion to canonical units internally
;  mu - gravity parameter, implies distance and time units
;output
;  ev= eccentricity vector. Follows grid-ness of r. Length is equal to eccentricity, points from center of attraction to periapse
;return
;  a structure, fields of which are either scalar or grids depending on grid-ness of r
;    p:  semi-parameter, distance from focus to orbit at TA=+-90deg, in original distance units, always positive for any eccentricity
;    a:  semimajor axis, in original distance units
;    e:  eccentricity
;    i:  inclination, radians
;    an: longitude of ascending node, angle between x axis and line of intersection between orbit plane and xy plane, radians
;    ap: argument of periapse, angle between xy plane and periapse along orbit plane, radians
;    ta: true anomaly, angle between periapse and object, radians
;    tp: time to next periapse original time units. Negative if only one periapse and in the past
;    rp: radius of periapse in original distance units
function elorb,r_,v_,l_DU,mu,ev=ev
  tau=2d*!dpi ;Tau manifesto
  rv=su_to_cu(r_,l_DU,mu,1,0)
  vv=su_to_cu(v_,l_DU,mu,1,-1)
  r=vlength(rv)
  v=vlength(vv)
  
  hv=crossp_grid(rv,vv)
  h=vlength(hv)
  nv=crossp_grid([0,0,1],hv)
  n=vlength(nv)
  ev=smult_grid((v^2-1d/r),rv)-smult_grid(dotp(rv,vv),vv)
  e=vlength(ev)
  
  xi=v^2/2d -1/r
  if n_elements(xi) eq 1 then begin
    a=0d
    p=0d
  end else begin
    a=dblarr(size(xi,/dim))
    p=dblarr(size(xi,/dim))
  end
  w=where(e ne 1.0,count)
  if count gt 0 then begin
    a[w]=-1/(2*xi[w])
    p[w]=a[w]*(1-e[w]^2)
  end
  w=where(e eq 1.0,count)
  if count gt 0 then begin
    ;parabolic case
    p[w]=h[w]^2
    a[w]=!values.d_infinity
  end
  resolve_grid,hv,x=hx,y=hy,z=hz
  resolve_grid,nv,x=nx,y=ny,z=nz
  i=acos(hz/h)
  an=acos(nx/n)
  w=where(ny lt 0,count)
  if count gt 0 then an[w]=tau-an[w]
  ap=vangle(ev,nv)
  resolve_grid,ev,x=ex,y=ey,z=ez
  w=where(ez lt 0,count)
  if count gt 0 then ap[w]=tau-ap[w]
  ta=vangle(ev,rv)
  w=where(dotp(rv,vv) lt 0,count)
  if count gt 0 then ta[w]=tau-ta[w]
  if n_elements(a) eq 1 then begin
    rp=0d
    n=0d
    MM=0d
  end else begin
    rp=dblarr(size(a,/dim))
    n=dblarr(size(a,/dim))
    MM=dblarr(size(a,/dim))
  end
  w=where(a gt 0,count)
  if count gt 0 then begin
    EE=2*atan(sqrt((1d -e[w])/(1d +e[w]))*tan(ta[w]/2d))
    MM[w]=EE-e[w]*sin(EE)
    n[w]=sqrt(1d/(a[w]^3))
    rp[w]=a[w]*(1d -e)
  end
  w=where(a lt 0,count)
  if count gt 0 then begin
    EE=asinh(sin(ta[w])*sqrt(e[w]^2-1)/(1d +e[w]*cos(ta[w])))
    MM[w]=e[w]*sinh(EE)-EE
    n[w]=sqrt(-1d/(a[w]^3))
    rp[w]=a[w]*(1d -e[w])
  end
  w=where(~finite(a),count)
  if count gt 0 then begin
    EE=tan/2
    MM[w]=EE^3/3d +EE
    n[w]=sqrt(2d/(p[w]^3))
    rp[w]=p[w]/2
  end
  tp=-MM/n
  return,{p:su_to_cu(p,l_du,mu,1,0,/inv),   $
          a:su_to_cu(a,l_du,mu,1,0,/inv),   $
          e:e,                              $
          i:i,                              $
          an:an,                            $
          ap:ap,                            $
          ta:ta,                            $
          tp:su_to_cu(tp,l_du,mu,0,1,/inv), $
          rp:su_to_cu(rp,l_du,mu,1,0,/inv),  $
          MM:MM, $
          n:su_to_cu(n,l_du,mu,0,-1,/inv), $
          t:su_to_cu(2*!dpi*sqrt(a^3),l_du,mu,0,1,/inv) $
          }
end
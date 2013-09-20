function fd_blackbrant,t,x
  r=x[0:2]
  v=x[3:5]
  a=x[6:8]
  q=x[9:12]
  w=x[13:15]
  m=x[16]+blackbrant_drymass(t)
  
  ;gravity
  a_grav=grav(r)
  
  ;ground support
  if t lt 0 then begin
    ;centripetal force keeping the rocket the same distance from the axis
    v_cf=vlength(v[0:1])
    r_cf=vlength(r[0:1])
    a_cf=[-r[0:1]*v_cf^2/r_cf^2,0]
    a_ground=-grav(r)+a_cf
  end else begin
    a_ground=[0d,0,0]
  end

  ;drag
  vrel=v-vwind(r)
  v2=dotp(vrel,vrel)
  if v2 eq 0 then a_drag=[0d,0,0] else begin
    vh=normalize_grid(vrel)
    scale_height=11000d
    rho0=1.22500d
    rho=rho0*exp(-(vlength(r)-6378137d)/scale_height)
    CdA=0.045d
    if t lt 6.2 then CdA*=2
    if t gt 400 then CdA=2
    dynpres=rho*v2*0.5d
    a_drag=-vh*CdA*dynpres/m
  end

  ;thrust
  if t lt 0 then begin
    v_e=0
    md=0
  end else if t lt 6.2 then begin
    v_e=2305.3782d;
    md=-110.56021d;
  end else if t lt 12 then begin
    v_e=0;
    md=0;
  end else if t lt 50.22 then begin
    v_e=2305.3782;
    md=-26.548466d;
  end else begin
    v_e=0;
    md=0;
  end
  FF=-md*v_e
  a=FF/m
  ;state quaternion is r2b, so use conjugate to get b2r
  f=quat_vect_mult([-q[0:2],q[3]],[0d,0,1d]) ;Thrust direction is body +Z axis
  a_thrust=f*a
  
  ;roll rate
  if t lt 0 then begin
    wzd=0
  end else if t lt 6.2 then begin
    dwz=2d*(2d*!dpi) ;change in rotation rate over this segment, rad/s
    dt=6.2           ;length of this segment, s
    wzd=dwz/dt
  end else if t lt 12 then begin
    dwz=(1.4d -2d)*(2d*!dpi)
    dt=12d -6.2
    wzd=dwz/dt
  end else if t lt 50.22 then begin
    dwz=(4.4d -1.4d)*(2d*!dpi)
    dt=50.22d -12d
    wzd=dwz/dt
  end else if t lt 90 then begin
    dwz=0
    dt=90d -50.22d
    wzd=dwz/dt
  end else if t lt 95 then begin
    dwz=(0d - 4.4d)*(2d*!dpi)
    dt=95d -90d
    wzd=dwz/dt
  end else begin
    wzd=0
  end
  wd=[0,0,wzd]
  qd=quat_mult_grid(q,[w,0d])/2

  ;return results
  xd=x
  xd[*]=0
  xd[0:2]=v
  xd[3:5]=a_grav+a_drag+a_thrust+a_ground
  xd[6:8]=0
  xd[9:12]=qd
  xd[13:15]=wd
  xd[16]=md
  return,xd
end


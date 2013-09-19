;state vector
;[r{3},v{3},a{3},q{4},w{3},m{1}]
;r=x[0:2]
;v=x[3:5]
;a=x[6:8]
;q_r2b=x[9:12]
;w=x[13:15]
;m=x[16]

function drymass,t
  m=t
  m[*]=443.89                   ;payload mass
  w=where(t lt 90,count)
  if count gt 0 then m[w]+=273.784 ;black brant shell mass
  w=where(t lt 6.2,count)
  if count gt 0 then m[w]+=320.504  ;terrier shell mass
  return,m
end

function grav,r
  return,-398600.4415e9*r/(vlength(r)^3)
end

function vwind,r
  return,crossp_grid([0,0,7.2921150000E-05],r)
end

function fd_blackbrant,t,x
  r=x[0:2]
  v=x[3:5]
  a=x[6:8]
  q=x[9:12]
  w=x[13:15]
  m=x[16]+drymass(t)
  ;gravity
  a_grav=grav(r)

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
  if t lt 6.2 then begin
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
  if t lt 6.2 then begin
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
  xd[3:5]=a_grav+a_drag+a_thrust
  xd[6:8]=0
  xd[9:12]=qd
  xd[13:15]=wd
  xd[16]=md
  return,xd
end

function g_rocketometer,t,x 
  r=x[0:2]
  v=x[3:5]
  a=x[6:8]
  q=x[9:12]
  w=x[13:15]
  m=x[16]+drymass(t)
  a=a-grav(r) ;non-grav acceleration in reference frame
  a=quat_vect_mult(q,a) 
  a_dn=a*32768/160
;  a_dn+=randomn(seed,n_elements(a_dn))*11
;  a_dn=a_dn>(-32768)<(32767)
;  a_dn=fix(a_dn)

;local topocentric system
  lla=xyz_to_lla(r)
  
  z=llr_to_xyz([lla[0],lla[1],1])
  e=normalize_grid(crossp_grid([0d,0,1],z))
  n=normalize_grid(crossp_grid(z,e))
;magnetic field in local system
  b_ned=wmm2010(lla,2013.8)*1d-9*1d4 ;convert from nanoTesla to Gauss  
  b_i=b_ned[0]*n+b_ned[1]*e-b_ned[2]*z
  b_dn=quat_vect_mult(q,b_i)*1090; Rocketometer runs at HMC5883L gain setting 1, 1090DN/Gauss
; b_dn=dblarr(3)
;body frame rotation rate  
  g_dn=w*32768/(2000*!dtor)
  return,transpose([a_dn[*],b_dn[*],g_dn[*]]) ;accelerometer measurement
end

pro blackbrant_sim
  tic
  launch_el=86.6d*!dtor ;degrees above horizon
  launch_az=   9d*!dtor ;degrees East of true North
  rail_exit_spd=43d
  rail_alt=1200d
  launch_lat=  32.41785*!dtor
  launch_lon=-106.31994*!dtor
  
  ;state at rail exit
  r0=xyz_to_lla(/inv,[launch_lat,launch_lon,rail_alt])
  t0=0.6d
  m0=1700.15+t0*(-110.56021d) ;mass of fuel only, at rail exit
  
  ;local topocentric system - Z points at zenith, E points at East in horizon, N points at North in horizon
  z=normalize_grid(r0)
  e=normalize_grid(crossp_grid([0d,0,1],z))
  n=normalize_grid(crossp_grid(z,e))
  
  p_r=transpose(z*sin(launch_el)+e*sin(launch_az)*cos(launch_el)+n*cos(launch_az)*cos(launch_el))
  t_r=transpose(e)
  
  ;body axis - Z is towards nose, X and Y are perpendicular. X is arbitrarily "left wing" and Y is arbitrarily "tail"
  p_b=transpose([0d,0,1])
  t_b=transpose([0d,1,0])
  ;point_toward returns a b2r matrix, we want an r2b quaternion
  q0=quat_to_mtx(/inv,transpose(point_toward(p_r=p_r,p_b=p_b,t_r=t_r,t_b=t_b)))
    
  v0=p_r*rail_exit_spd+vwind(r0)
  w0=[0d,0,0]  ;body rotation rates, rad/s
  dt=0.003d   ;match the sample rate of the sensors
  t1=1000d;
  x0=transpose([r0,v0[*],[0,0,0],q0[*],w0,m0])
  n=floor((t1-t0)/dt)
  t=dindgen(n)*dt+t0
  x=dblarr(n,n_elements(x0))
  xd=x
  x[0,*]=x0
  z0=g_rocketometer(t0,x0) ;measurement vector, for size only
  z=dblarr(n,n_elements(z0))
  z[0,*]=z0
  i=1L
  while vlength(x[i-1,0:2]) gt vlength(r0)-1 and i lt n_elements(t) do begin
    xd[i,*]=call_function('fd_blackbrant',t[i],x[i-1,*])
    x[i,*]=x[i-1,*]+dt*xd[i,*]
    x[i,6:8]=xd[i,3:5] ;stick acceleration into state vector
    x[i,9:12]=x[i,9:12]/sqrt(total(x[i,9:12]^2)) ;renormalize quaternion
    z[i,*]=call_function('g_rocketometer',t[i],x[i,*])
    i++
  end 
  t=t[0:i-1]
  xd=xd[0:i-1,*]
  x=x[0:i-1,*]
  z=z[0:i-1,*]
  save,filename='BlackBrantClean.sav',/compress
  toc
  stop
end
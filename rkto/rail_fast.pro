function twobody,rv
  mu=398600436233000.00d  
  return,-mu*rv/(vlength(rv)^3)
end

function j2grav,rv
  mu=398600436233000d  
  J2=0.001082616d 
  re=6378136.6d  
  
  r=vlength(rv)
  resolve_grid,rv,x=x,y=y,z=z
  coef=-3d*J2*mu*re^2d/(2d*r^5d)
  ax=coef*x*(1d -5d*z^2d/r^2d)
  ay=coef*y*(1d -5d*z^2d/r^2d)
  az=coef*z*(3d -5d*z^2d/r^2d)
  return,compose_grid(ax,ay,az)
end

function grav,rv
  return,twobody(rv)+j2grav(rv)
end

function ntohl,data,i
  return,ulong(uint(data[i,*]))*65536+uint(data[i+1,*])
end
pro rail_fast
  defsysv,'!tau',2.0d*!dpi ; Tau manifesto, Tau is especially convenient for converting to radians
  swindow,0
  device,dec=1
  data=read_binary('ouf010.sds',data_t=2,endian='big')
  help,data
  data=reform(data,17,n_elements(data)/17)
  seq=ntohl(data,0)
  ;_T_ime _c_ount of the _M_PU6050 sensor, converted to seconds from range 0
  tcm=fix_tc(/sec,ntohl(data,2))
  ;_M_PU6050 _A_ccelerometer _X_ raw data
  max=data[ 4,*]
  ;_M_PU6050 _A_ccelerometer _Y_ raw data
  may=data[ 5,*]
  ;_M_PU6050 _A_ccelerometer _Z_ raw data
  maz=data[ 6,*]
  ;_M_PU6050 _G_yro _X_ raw data
  mgx=data[ 7,*]
  ;_M_PU6050 _G_yro _X_ raw data
  mgy=data[ 8,*]
  ;_M_PU6050 _G_yro _X_ raw data
  mgz=data[ 9,*]
  ;_M_PU6050 _T_emperature raw data
  mt =data[10,*]
  ;_H_ighAcc _X_ raw data
  hx=data[11,*] mod 4096
  ;_H_ighAcc _Y_ raw data
  hy=data[12,*] mod 4096
  ;_H_ighAcc _Z_ raw data
  hz=data[13,*] mod 4096
  ;_T_ime _C_ount of the _M_PU6050 sensor readout finish
  tcm1=fix_tc(/sec,ntohl(data,14))
  ;The numerator of the fraction is my best estimate of true measurable acceleration of gravity at launch site, in m/s^2, taking
  ;into account altitude above geoid, slab gravity, and centrifugal force from rotation of the Earth. The denominator is the 
  ;measured total acceleration using the nameplate sensitivity and 1g=10m/s^2 exactly (so we expect a bit of error)
  ;phyrange=160.0d *9.79280914d/10.2654d
  ;nameplate sensitivity of the accelerometers
  phyrange=16d*(9.80665d);*9.79280914/10.2654
  dnrange=32768.0
  ;Numerator is number of roll rotations measured on the way up before despin measured by the compass, denominator is same measured
  ;by gyroscope. The rest is the nameplate rotation sensitivity
  phygrange=2000.0*(218.0/216.25)/360.0*!tau;rad/sec
  dngrange=32768.0

  restore,'../flight36.290/poly.sav'
  
  ;Use the constant coefficient to subtract off the sensor zero-g bias. We will do the linear as well, just because it's there. Scale the 
  ;measurements to physical units based on phyrange
  ;_M_PU6050 _A_cceleration _X_ axis _P_hysical units (m/s^2)
  maxp= (max-poly(mt,maxf))*phyrange/dnrange
  ;_M_PU6050 _A_cceleration _Y_ axis _P_hysical units (m/s^2)
  mayp= (may-poly(mt,mayf))*phyrange/dnrange
  ;_M_PU6050 _A_cceleration _Z_ axis _P_hysical units (m/s^2)
  mazp= (maz-poly(mt,mazf))*phyrange/dnrange
  ;_M_PU6050 _G_yroscope _X_ axis _P_hysical units (rad/s)
  mgxp= (mgx-poly(mt,mgxf))*phygrange/dngrange
  ;_M_PU6050 _G_yroscope _Y_ axis _P_hysical units (rad/s)
  mgyp= (mgy-poly(mt,mgyf))*phygrange/dngrange
  ;_M_PU6050 _G_yroscope _Z_ axis _P_hysical units (rad/s)
  mgzp= (mgz-poly(mt,mgzf))*phygrange/dngrange

  matp=sqrt(maxp^2+mayp^2+mazp^2)
  mgtp=sqrt(mgxp^2+mgyp^2+mgzp^2)
  ;Plot rotation rate around each axis and total in rev/s
  print,"Nameplate sensitivity in rev/s: ",2000.0/360.0
  print,"Nameplate sensitivity in rad/s: ",2000.0/360.0*!tau
  !p.multi=0
  plot,tcm, mgtp,xrange=[10,20],yrange=[-12,12],xtitle='Range time s',ytitle='Acceleration m/s^2',/ys
  oplot,tcm,maxp,color='0000ff'x
  oplot,tcm,mayp,color='00ff00'x
  oplot,tcm,mazp,color='ff8080'x
  ;_H_ighacc _X_ _P_hysical (m/s^2)  
  hxp=(hx-hxm)*phyrangeh/dnrangeh
  ;_H_ighacc _Y_ _P_hysical (m/s^2)  
  hyp=(hy-hym)*phyrangeh/dnrangeh
  ;_H_ighacc _Z_ _P_hysical (m/s^2)  
  hzp=(hz-hzm)*phyrangeh/dnrangeh
 
  ;initial conditions. Coordinate system is geocentric inertial system parallel to ECEF at t0, hereafter called GCI. After this time,
  ;the launch site moves to the east in this coordinate system
  lat0=!dtor*32.417995d
  lon0=-106.32016d*!dtor
  alt0=1209
  el0=86.6d*!dtor
  az0=352d*!dtor
  ;point the nose (p_b) at the sky (p_r), gravity vector (t_b) toward local vertical (t_r)
  ;zz - topocentric zenith vector at launch site at t0 in GCI, perpendicular to ellipsoid at launch site
  zz=[cos(lat0)*cos(lon0),cos(lat0)*sin(lon0),sin(lat0)]
  ;_t_oward vector in _r_eference frame 
  t_r=zz
  w=max(where(tcm lt -1.0))
  t_b=normalize_grid([maxp[w],mayp[w],mazp[w]])
  ;ee - topocentric east vector at launch site at t0 in GCI. In topocentric horizon plane, perpendicular to zz, pointing due east
  ee=normalize_grid(crossp_grid([0,0,1],zz))
  ;nn - topocentric north vector at launch site at t0 in GCI. In topocentric horizon plane, perpendicular to zz, pointing due north
  nn=normalize_grid(crossp_grid(zz,ee))
  ;_p_oint vector in _r_eference frame - from elevation and azimuth, but in GCI
  p_r=zz*sin(el0)+nn*cos(el0)*cos(az0)+ee*cos(el0)*sin(az0)
  ;_p_oint vector in _b_ody rocketometer frame - presuming perfect mount, Z axis of rocketometer antiparallel to rocket roll axis
  p_b=[0,0,-1]
  M_br=point_toward(p_r=transpose(p_r),p_b=transpose(p_b),t_r=transpose(t_r),t_b=transpose(t_b))
  print,m_br
  q0_br=quat_to_mtx(/inv,M_br)
  print,q0_br
  nose_i=M_br ## transpose([0,0,-1])
  print,"Elevation: ",asin(dotp(nose_i,zz))*!radeg
  print,"Azimuth:   ",atan(dotp(nose_i,ee),dotp(nose_i,nn))*!radeg
  nose_i=quat_vect_mult(quat_invert(q0_br),[0,0,-1])
  print,"Elevation: ",asin(dotp(nose_i,zz))*!radeg
  print,"Azimuth:   ",atan(dotp(nose_i,ee),dotp(nose_i,nn))*!radeg
  
  r0=lla_to_xyz(lat=lat0,lon=lon0,alt=alt0)
  w0=!tau/86164.09d
  v0=crossp_grid([0,0,w0],r0)
  
  ;Integrate rotation rate to get quaternions for each point in time after t0
  dtcm=tcm-shift(tcm,1)
  w=where(tcm gt 0 and tcm lt 1000,count)
  dtcm=dtcm[w]
  tcm=tcm[w]
  mgxp=mgxp[w]
  mgyp=mgyp[w]
  mgzp=mgzp[w]
  maxp=maxp[w]
  mayp=mayp[w]
  mazp=mazp[w]
  map=compose_grid(maxp,mayp,mazp)
  mgp=compose_grid(mgxp,mgyp,mgzp)
  q_br=dblarr(count,4)
  q_br[0,*]=q0_br
  r=dblarr(count,3)
  r[0,*]=r0
  v=dblarr(count,3)
  v[0,*]=v0
  a_ng_i=r
  a_i=r
  for i=1,count-1 do begin
    dqdt=0.5d*quat_mult(q_br[i-1,*],[transpose(mgp[i,*]),0])
    q_br[i,*]=q_br[i-1,*]+dqdt*dtcm[i]
    q_br[i,*]=quat_normalize(q_br[i,*])
    a_ng_i[i,*]=quat_vect_mult(quat_invert(q_br[i,*]),map[i,*])
    a_i[i,*]=a_ng_i[i,*]+grav(transpose(r[i-1,*]))
    v[i,*]=v[i-1,*]+a_i[i,*]*dtcm[i]
    r[i,*]=r[i-1,*]+v[i,*]*dtcm[i]
    if i mod 10000 eq 0 then print,i,tcm[i]
  end
  stop
end
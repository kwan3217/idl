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
pro integrate_fast
  defsysv,'!tau',2.0d*!dpi ; Tau manifesto, Tau is especially convenient for converting to radians
  t0=2019.0; Range Zero - TC converted into seconds but counted from timer startup. First data point which sees dynamic acceleration is first point after this time
;  swindow,0
;  device,dec=1
  data=read_binary('ouf010.sds',data_t=2,endian='big')
  help,data
  data=reform(data,17,n_elements(data)/17)
  seq=ntohl(data,0)
  ;_T_ime _c_ount of the _M_PU6050 sensor, converted to seconds from range 0
  tcm=fix_tc(/sec,ntohl(data,2))-t0
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
  tcm1=fix_tc(/sec,ntohl(data,14))-t0
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
  ;Rocket was floating throug space at an acceleration indistinguishable from zero G during this range time
  t0g=[130,470]
  w0g=where(tcm gt t0g[0] and tcm lt t0g[1])
  phyrangeh=2000;
  dnrangeh=2048
  ;_H_ighacc _X_ _m_ean during zero-g coast
  hxm=mean(hx[w0g])
  ;_H_ighacc _Y_ _m_ean during zero-g coast
  hym=mean(hy[w0g])
  ;_H_ighacc _Z_ _m_ean during zero-g coast
  hzm=mean(hz[w0g])
  print,"hm",hxm,hym,hzm
  print,"hs",stdev(hx[w0g]),stdev(hy[w0g]),stdev(hz[w0g])
  
  ;Attempt to find temperature coefficients of acceleration bias in each axis
  ;First column of printout is label
  ;Second is constant coefficient
  ;Third is linear coefficient
  ;Fourth is stdev of all zero-g data
  ;Fifth is stdev of residual from linear fit
  ;Sixth is r^2 coefficient, fraction of stdev explained by fit
;  plot,tcm,mt
;  !p.multi=[0,3,2]
  maxf=linfit(mt[w0g],max[w0g],yfit=yfit) & print,"max || ",maxf[0],"||",maxf[1],"||",stdev(max[w0g]),"||",stdev(yfit-max[w0g]),"||",1-(stdev(yfit-max[w0g])/stdev(max[w0g]))
;  plot,mt[w0g],max[w0g],psym=3,/ynoz,charsize=2,xtitle='Temperature DN',ytitle='X acceleration DN'
;  oplot,mt[w0g],yfit,color='0000ff'x
  mayf=linfit(mt[w0g],may[w0g],yfit=yfit) & print,"may || ",mayf[0],"||",mayf[1],"||",stdev(may[w0g]),"||",stdev(yfit-may[w0g]),"||",1-(stdev(yfit-may[w0g])/stdev(may[w0g]))
;  plot,mt[w0g],may[w0g],psym=3,/ynoz,charsize=2,xtitle='Temperature DN',ytitle='Y acceleration DN'
;  oplot,mt[w0g],yfit,color='0000ff'x
  mazf=linfit(mt[w0g],maz[w0g],yfit=yfit) & print,"maz || ",mazf[0],"||",mazf[1],"||",stdev(maz[w0g]),"||",stdev(yfit-maz[w0g]),"||",1-(stdev(yfit-maz[w0g])/stdev(maz[w0g]))
;  plot,mt[w0g],maz[w0g],psym=3,/ynoz,charsize=2,xtitle='Temperature DN',ytitle='Z acceleration DN'
;  oplot,mt[w0g],yfit,color='0000ff'x
  
  ;Same for gyro coefficients
  mgxf=linfit(mt[w0g],mgx[w0g],yfit=yfit) & print,"mgx || ",mgxf[0],"||",mgxf[1],"||",stdev(mgx[w0g]),"||",stdev(yfit-mgx[w0g]),"||",1-(stdev(yfit-mgx[w0g])/stdev(mgx[w0g]))
;  plot,mt[w0g],mgx[w0g],psym=3,/ynoz,charsize=2,xtitle='Temperature DN',ytitle='X rotation rate DN'
;  oplot,mt[w0g],yfit,color='0000ff'x
  mgyf=linfit(mt[w0g],mgy[w0g],yfit=yfit) & print,"mgy || ",mgyf[0],"||",mgyf[1],"||",stdev(mgy[w0g]),"||",stdev(yfit-mgy[w0g]),"||",1-(stdev(yfit-mgy[w0g])/stdev(mgy[w0g]))
;  plot,mt[w0g],mgy[w0g],psym=3,/ynoz,charsize=2,xtitle='Temperature DN',ytitle='Y rotation rate DN'
;  oplot,mt[w0g],yfit,color='0000ff'x
  mgzf=linfit(mt[w0g],mgz[w0g],yfit=yfit) & print,"mgz || ",mgzf[0],"||",mgzf[1],"||",stdev(mgz[w0g]),"||",stdev(yfit-mgz[w0g]),"||",1-(stdev(yfit-mgz[w0g])/stdev(mgz[w0g]))
;  plot,mt[w0g],mgz[w0g],psym=3,/ynoz,charsize=2,xtitle='Temperature DN',ytitle='Z rotation rate DN'
;  oplot,mt[w0g],yfit,color='0000ff'x

  save,maxf,mayf,mazf,mgxf,mgyf,mgzf,file='../flight36.290/poly.sav' 
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
  xrange=[76,81]
  xrange_fullspin=[60,70]
  w=where(tcm ge 60 and tcm lt 70,count)
  print,"Mean full-spin speed (rad/s): ",mean(mgtp[w])
;  plot,tcm, mgtp,xrange=xrange,yrange=[-phygrange,phygrange],xtitle='Range time s',ytitle='Rotation rate rev/sec',/ys,/xs
;  oplot,tcm,mgxp,color='0000ff'x
;  oplot,tcm,mgyp,color='00ff00'x
;  oplot,tcm,mgzp,color='ff0000'x
;  plot,tcm, matp,xrange=xrange,yrange=[-20,20],xtitle='Range time s',ytitle='Acceleration m/s^2',/ys,/xs
;  oplot,tcm,maxp,color='0000ff'x
;  oplot,tcm,mayp,color='00ff00'x
;  oplot,tcm,mazp,color='ff0000'x
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
  a_ng_i=r*0
  a_i=r*0
  openw,ouf,/get_lun,'NASA36_290.inc'
  printf,ouf,format='(%"#declare State=array[%d][5] {")',count
  printf,ouf,"//r_x                     r_y                      r_z                     t                         q_x                     q_y                     q_z                     q_w                       v_x                    v_y                      v_z                         a_x                      a_y                     a_z"
  printf,ouf,format='(%"{<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>},")', $
    r[0,*],tcm[0],q_br[0,*],v[0,*],a_i[0,*],a_ng_i[0,*]
  for i=1,count-1 do begin
    dqdt=0.5d*quat_mult(q_br[i-1,*],[transpose(mgp[i,*]),0])
    q_br[i,*]=q_br[i-1,*]-dqdt*dtcm[i]
    q_br[i,*]=quat_normalize(q_br[i,*])
    a_ng_i[i,*]=quat_vect_mult(quat_invert(q_br[i,*]),map[i,*])
    a_i[i,*]=a_ng_i[i,*]+grav(transpose(r[i-1,*]))
    v[i,*]=v[i-1,*]+a_i[i,*]*dtcm[i]
    r[i,*]=r[i-1,*]+v[i,*]*dtcm[i]
    if i mod 10000 eq 0 then print,i,tcm[i]
    printf,ouf,format='(%"{<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>},")', $
    r[i,*],tcm[i],q_br[i,*],v[i,*],a_i[i,*],a_ng_i[i,*]
  end
  printf,ouf,"}"
  free_lun,ouf
  fps=30
  openw,ouf,/get_lun,string(fps,format='(%"NASA36_290_%02dfps.inc")')
  t_fps=dindgen((tcm[-1]-tcm[0])*30d)/30d
  n_fps=n_elements(t_fps)
  printf,ouf,format='(%"#declare State=array[%d][5] {")',n_fps
  printf,ouf,"//r_x                     r_y                      r_z                     t                         q_x                     q_y                     q_z                     q_w                       v_x                    v_y                      v_z                         a_x                      a_y                     a_z"
  r_fps=dblarr(n_fps,3)
  for i=0,2 do r_fps[*,i]=interpol(r[*,i],tcm,t_fps)
  v_fps=dblarr(n_fps,3)
  for i=0,2 do v_fps[*,i]=interpol(v[*,i],tcm,t_fps)
  a_fps=dblarr(n_fps,3)
  for i=0,2 do a_fps[*,i]=interpol(a_i[*,i],tcm,t_fps)
  a_ng_fps=dblarr(n_fps,3)
  for i=0,2 do a_ng_fps[*,i]=interpol(a_ng_i[*,i],tcm,t_fps)
  q_fps=dblarr(n_fps,4)
  for i=0,3 do q_fps[*,i]=interpol(q_br[*,i],tcm,t_fps)
  for i=0,n_fps-1 do begin
    printf,ouf,format='(%"{<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>},")', $
    r_fps[i,*],t_fps[i],q_fps[i,*],v_fps[i,*],a_fps[i,*],a_ng_fps[i,*]
  end
  printf,ouf,"}"
  free_lun,ouf
end

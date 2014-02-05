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
pro pkto_fast
  defsysv,'!tau',2.0d*!dpi ; Tau manifesto, Tau is especially convenient for converting to radians
  swindow,0
  device,dec=1
  data=read_binary('RKTO0000_010_12.sds',data_t=2,endian='big')
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
  
;  restore,'Sensor20131119T100534.sav'
  
;  wa=where(data.sensortype eq 1)
;  wg=where(data.sensortype eq 4)
;  ta=(data.timestamp[wa]-data.timestamp[0])/1d9
;  tg=(data.timestamp[wg]-data.timestamp[0])/1d9
;  sax=data.sensorx[wa]
;  say=data.sensory[wa]
;  saz=data.sensorz[wa]
;  sgx=data.sensorx[wg]
;  sgy=data.sensory[wg]
;  sgz=data.sensorz[wg]
;  sat=sqrt(sax^2+say^2+saz^2)
;  sgt=sqrt(sgx^2+sgy^2+sgz^2)
  
  !p.multi=0
  tmajor=1d
  tunit='s'
  amajor=9.80665d
  aunit='g'
  gmajor=!dtor
  gunit='deg/s'
  t0=2*60d + 20
  t0_avg_g=t0-3
  t1=t0+1*60d +30d
  t1_avg_g=t1+10
  w_all=where(tcm ge t0_avg_g and tcm lt t1_avg_g)


  dtcm=tcm-shift(tcm,1)
  dtcm=dtcm[w_all]
  tcm=tcm[w_all]-t0
  t1=t1-t0
  t1_avg_g=t1_avg_g-t0
  t0_avg_g=t0_avg_g-t0
  t0=0
  mgxp=mgxp[w_all]
  mgyp=mgyp[w_all]
  mgzp=mgzp[w_all]
  mgtp=mgtp[w_all]
  maxp=maxp[w_all]
  mayp=mayp[w_all]
  mazp=mazp[w_all]
  matp=matp[w_all]
  w_avg_g0=where(tcm lt 0)
  w_ride=where(tcm ge 0 and tcm lt t1)
  w_avg_g1=where(tcm ge t1)
  mgxp-=mean(mgxp[w_avg_g0])
  mgyp-=mean(mgyp[w_avg_g0])
  mgzp-=mean(mgzp[w_avg_g0])
  map=compose_grid(maxp,mayp,mazp)
  mgp=compose_grid(mgxp,mgyp,mgzp)
  sconst=100
  smatp=smooth(matp,sconst)
  smaxp=smooth(maxp,sconst)
  smayp=smooth(mayp,sconst)
  smazp=smooth(mazp,sconst)
  smgtp=smooth(mgtp,sconst)
  smgxp=smooth(mgxp,sconst)
  smgyp=smooth(mgyp,sconst)
  smgzp=smooth(mgzp,sconst)
  yarange=[-max(smatp),max(smatp)]/amajor
;  ygrange=[-max(smgtp),max(smgtp)]/gmajor
  ygrange=[-1,1]*0.5
  ;initial conditions. Coordinate system is pseudoinertial track-fixed with its origin at the Rocketometer position ride time 0
  ;z axis is at local vertical, parallel to Rocketometer measured acceleration during average-g. Rocketometer X axis at t0 is
  ;towards pseudoinertial X axis.
  ;the launch site moves to the east in this coordinate system

  ;point the measured body gravity vector (p_b) at the sky (p_r), x body axis (t_b) toward x pseudoinertial (t_r)
  ;zz - topocentric zenith vector at launch site at t0 in GCI, perpendicular to ellipsoid at launch site
  p_r=[0,0,1]
  ;_p_oint vector in _b_ody rocketometer frame
  p_b=[mean(maxp[w_avg_g0]),mean(mayp[w_avg_g0]),mean(mazp[w_avg_g0])]
  g0=vlength(p_b)
  p_b=normalize_grid(p_b)
  a_g=[0,0,-g0]
  t_b=[1,0,0]
  t_r=[1,0,0]
  M_br=point_toward(p_r=transpose(p_r),p_b=transpose(p_b),t_r=transpose(t_r),t_b=transpose(t_b))
  print,m_br
  q0_br=quat_to_mtx(/inv,M_br)
  print,q0_br

  r0=[0,0,0]
  v0=[0,0,0]
  
  ;Integrate rotation rate to get quaternions for each point in time after t0
    !p.multi=[0,1,2]
     plot,[0,0],[0,0],xrange=[t0_avg_g,t1_avg_g],yrange=yarange,xtitle='Range time '+tunit,ytitle='Acceleration '+aunit,/ys,/nodata
     oplot,[0,0],yarange,color='00ff00'x
     oplot,[1,1]*t1/tmajor,yarange,color='00ff00'x
    oplot,tcm, matp/amajor,color='808080'x
    oplot,tcm, maxp/amajor,color='000080'x
    oplot,tcm, mayp/amajor,color='008000'x
    oplot,tcm, mazp/amajor,color='800000'x
    oplot,tcm,smatp/amajor,color='ffffff'x
    oplot,tcm,smaxp/amajor,color='0000ff'x
    oplot,tcm,smayp/amajor,color='00ff00'x
    oplot,tcm,smazp/amajor,color='ff0000'x
     plot,tcm, mgtp/gmajor,xrange=xrange,yrange=ygrange,xtitle='Range time min',ytitle='Rotation deg/s',/ys,/nodata
    oplot,tcm, mgtp/gmajor,color='808080'x
    oplot,tcm, mgxp/gmajor,color='000080'x
    oplot,tcm, mgyp/gmajor,color='008000'x
    oplot,tcm, mgzp/gmajor,color='800000'x
    oplot,tcm,smgtp/gmajor,color='ffffff'x
    oplot,tcm,smgxp/gmajor,color='0000ff'x
    oplot,tcm,smgyp/gmajor,color='00ff00'x
    oplot,tcm,smgzp/gmajor,color='ff0000'x
    oplot,[t0_avg_g,t1_avg_g],[0,0],color='ffffff'x
  count=n_elements(w_all)
  q_br=dblarr(count,4)
  q_br[0,*]=q0_br
  r=dblarr(count,3)
  r[0,*]=r0
  v_i=dblarr(count,3)
  v_i[0,*]=v0
  v_b=v_i
  a_ng_i=r
  a_i=r
  for i=1,count-1 do begin
    dqdt=0.5d*quat_mult(q_br[i-1,*],[transpose(mgp[i,*]),0])
    q_br[i,*]=q_br[i-1,*]-dqdt*dtcm[i]
    q_br[i,*]=quat_normalize(q_br[i,*])
    a_ng_i[i,*]=quat_vect_mult(quat_invert(q_br[i,*]),map[i,*])
    a_i[i,*]=a_ng_i[i,*]+a_g
    v_i[i,*]=v_i[i-1,*]+a_i[i,*]*dtcm[i]
    v_b[i,*]=quat_vect_mult(q_br[i,*],v_i[i,*])
    r[i,*]=r[i-1,*]+v_i[i,*]*dtcm[i]
    if i mod 10000 eq 0 then print,i,tcm[i]
  end
  ;At the end of the ride, v_i should be zero. Find out what it is, presume that it was
  ;added as a constant a_i vector, and figure that vector.
  w_avg_g1=where(tcm ge t1)
  a_i_end=[mean(a_i[w_avg_g1,0]),mean(a_i[w_avg_g1,1]),mean(a_i[w_avg_g1,2])]
  ;Reintegrate with a_i_end compensation
  q_br=dblarr(count,4)
  q_br[0,*]=q0_br
  r=dblarr(count,3)
  r[0,*]=r0
  v_i=dblarr(count,3)
  v_i[0,*]=v0
  a_ng_i=r
  a_i=r
  openw,ouf,/get_lun,'RockNRoller.inc'
  printf,ouf,format='(%"#declare State=array[%d][7] {")',count
  printf,ouf,"//r_x                     r_y                      r_z                     t                         q_x                     q_y                     q_z                     q_w                       v_x                    v_y                      v_z                         a_x                      a_y                     a_z"
  printf,ouf,format='(%"{<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>},")', $
    r[0,*],tcm[0],q_br[0,*],v_i[0,*],a_i[0,*],a_ng_i[0,*],map[0,*],mgp[0,*],v_b[0,*]
  for i=1,count-1 do begin
    dqdt=0.5d*quat_mult(q_br[i-1,*],[transpose(mgp[i,*]),0])
    q_br[i,*]=q_br[i-1,*]-dqdt*dtcm[i]
    q_br[i,*]=quat_normalize(q_br[i,*])
    a_ng_i[i,*]=quat_vect_mult(quat_invert(q_br[i,*]),map[i,*])
    a_i[i,*]=a_ng_i[i,*]+a_g-a_i_end*tcm[i]/t1
    v_i[i,*]=v_i[i-1,*]+a_i[i,*]*dtcm[i]
    r[i,*]=r[i-1,*]+v_i[i,*]*dtcm[i]
    if i mod 10000 eq 0 then print,i,tcm[i]
    printf,ouf,format='(%"{<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>},")', $
    r[i,*],tcm[i],q_br[i,*],v_i[i,*],a_i[i,*],a_ng_i[i,*],map[i,*],mgp[i,*],v_b[*,i]
  end
  printf,ouf,"}"
  free_lun,ouf
  fps=24d
  openw,ouf,/get_lun,string(fps,format='(%"RockNRoller_%02dfps.inc")')
  t_fps=dindgen((tcm[-1]-tcm[0])*fps)/fps
  n_fps=n_elements(t_fps)
  printf,ouf,format='(%"#declare State=array[%d][7] {")',n_fps
  printf,ouf,"//r_x                     r_y                      r_z                     t                         q_x                     q_y                     q_z                     q_w                       v_x                    v_y                      v_z                         a_x                      a_y                     a_z"
  r_fps=dblarr(n_fps,3)
  for i=0,2 do r_fps[*,i]=interpol(r[*,i],tcm,t_fps)
  v_i_fps=dblarr(n_fps,3)
  for i=0,2 do r_fps[*,i]=interpol(v_i[*,i],tcm,t_fps)
  v_b_fps=dblarr(n_fps,3)
  for i=0,2 do v_fps[*,i]=interpol(v_b[*,i],tcm,t_fps)
  a_i_fps=dblarr(n_fps,3)
  for i=0,2 do a_fps[*,i]=interpol(a_i[*,i],tcm,t_fps)
  a_ng_fps=dblarr(n_fps,3)
  for i=0,2 do a_ng_fps[*,i]=interpol(a_ng_i[*,i],tcm,t_fps)
  q_fps=dblarr(n_fps,4)
  for i=0,3 do q_fps[*,i]=interpol(q_br[*,i],tcm,t_fps)
  map_fps=dblarr(n_fps,3)
  for i=0,2 do map_fps[*,i]=interpol(map[*,i],tcm,t_fps)
  mgp_fps=dblarr(n_fps,3)
  for i=0,2 do mgp_fps[*,i]=interpol(mgp[*,i],tcm,t_fps)
  for i=0,n_fps-1 do begin
    printf,ouf,format='(%"{<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,%23.15e>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>,<%23.15e,%23.15e,%23.15e,0>},")', $
    r_fps[i,*],t_fps[i],q_fps[i,*],v_i_fps[i,*],a_i_fps[i,*],a_ng_fps[i,*],map_fps[i,*],mgp_fps[i,*],v_b_fps[i,*]
  end
  printf,ouf,"}"
  free_lun,ouf
  print,'done'
end
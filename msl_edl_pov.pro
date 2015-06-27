function twobody_grav,ri,mu
  r=sqrt(total(ri^2,1))
  return,-mu*ri/rebin(transpose(r^3),3,n_elements(r),/sample)
end

function n_lm,l,m
  if m eq 0 then delta=1 else delta=0
  return,sqrt((2-delta)*(2*l+1)*factorial(l-m)/factorial(l+m))
end

function cbar20_grav,ri,mu,rb,cbar20
  c20=cbar20/n_lm(2,0)
  r=sqrt(total(ri^2,1))
  x=ri[0,*]
  y=ri[1,*]
  z=ri[2,*]
  coef=3d*c20*mu*rb^2d/(2d*r^5d)
  ax=coef*x*(1d -5d*z^2d/r^2d)
  ay=coef*y*(1d -5d*z^2d/r^2d)
  az=coef*z*(3d -5d*z^2d/r^2d)
  return,[[ax],[ay],[az]]
end

function cbar30_grav,ri,mu,rb,cbar30
  c30=cbar30/n_lm(3,0)
  r=sqrt(total(ri^2,1))
  x=ri[0,*]
  y=ri[1,*]
  z=ri[2,*]
  
  ax=5d*c30*mu*rb^3d*x/(2d*r^7)*(3d*z-7d*z^3/r^2)
  ay=5d*c30*mu*rb^3d*y/(2d*r^7)*(3d*z-7d*z^3/r^2)
  az=transpose(5d*c30*mu*rb^3d/(2d*r^7)*(6d*z^2-7d*z^4/r^2-3d*r^2/5d))
  return,[ax,ay,az]
end

pro msl_edl_pov
  dlm_register,'C:\Users\jeppesen\Documents\LocalApps\spice\icy64_7\lib\icy.dlm'


  cspice_furnsh,'msl.tm'
  tt=msl_edl_t()
  dt=tt-shift(tt,1)
  dt[0]=dt[1]

  mars_a=3396.19d
  mars_b=3376.20d
  mars_f=1d -mars_b/mars_a
  tutc=strarr(n_elements(tt))
  for i=0,n_elements(tt)-1 do begin 
    cspice_timout,tt[i],'YYYY-MM-DDTHR:MN:SC.### ::UTC',30,this_tutc & tutc[i]=this_tutc
    cspice_spkezr,'MSL',tt[i],'IAU_MARS','NONE','MARS',state,ltime & rvrel[*,i]=state
    cspice_spkezr,'MSL',tt[i],'PHX_MME_2000','NONE','MARS',state,ltime & rvi[*,i]=state
    xyz2llagrid,rrel[0],rrel[1],rrel[2],mars_a,mars_f,lat=this_lat,lon=this_lon,alt=this_alt
    lla[*,i]=[this_lat,this_lon,this_alt]
  end
  
  ri=rvi[0:2,*]
  vi=rvi[3:5,*]
  rrel=rvrel[0:2,*]
  vrel=rvrel[3:5,*]
  r=sqrt(total(ri^2,1))
  airspd=sqrt(total(vrel^2,1))
  rei=3522.2
 
  ;from Goddard Mars Model 2 http://denali.gsfc.nasa.gov/697/MARS/GMM2B.html
  rb=3397d
  mu=4.2828371901284001d+04; 42828.371901(73)
  cbar20=-8.7450547081842009d-04
  cbar30=-1.1886910646015641d-05
  cbar40= 5.1257987175465586d-06
  cbar50=-1.7242068505338999d-06
  cbar60= 1.3448267510621481d-06

  ag=twobody_grav(ri,mu)+ $
     cbar20_grav(ri,mu,rb,cbar20);+ $
     ;cbar30_grav(ri,mu,rb,cbar30)
  dvi=vi-shift(vi,0,1)
  dvi[*,0]=dvi[*,1]
  ai=dvi/rebin(transpose(dt),3,n_elements(tt),/sample)
  gi=ai-ag ;inertial acceleration minus gravity, what an accelerometer feels
  gi_drag=gi*0
  tau=2*!dpi ;tau manifesto

  for i=0,n_elements(tt)-1 do begin 
    wind=crossp([0,0,350.89198226/86400d/360d*tau],ri[*,i])
    t=vi[*,i]-wind ;tangential vector, unit vector parallel to local relative speed in IAU_MME
    t=t/norm(t) 
    lv=[cos(lla[0,i])*cos(lla[1,i]),cos(lla[0,i])*sin(lla[1,i]),sin(lla[0,i])] ;local vertical
    w=crossp(lv,t) ;Out of plane vector, perpendicular to t and in horizontal plane, positive is north of plane
    w=w/norm(w)
    n=crossp(t,w) ;Normal vector, perpendicular to t and towards local vertical
    n=n/norm(n)
    Mmme2ntw=[[t],[w],[n]] ;drag, horizontal lift, vertical lift
    gi_drag[*,i]=Mmme2ntw ## gi[*,i]
    
  end
  
  g=sqrt(total(gi^2,1))

  ri=ri*1000d
  vi=vi*1000d
  ai=ai*1000d
  gi=gi*1000d
  rrel=rrel*1000d
  vrel=vrel*1000d
  airspd=airspd*1000d
  gi_drag=gi_drag*1000d

  openw,/get_lun,ouf,'msl_edl.inc'
  printf,ouf,'//MSL EDL predict SPICE to POV conversion v3, from JPL NAIF http://naif.jpl.nasa.gov'
  printf,ouf,'//Chris Jeppesen, 9 Jun 2011. kwan3217 on unmannedspaceflight.com'
  printf,ouf,'//T is time in seconds from beginning of data'
  printf,ouf,'//UTC string is in ISO date format'
  printf,ouf,'//Everything is in Spacecraft Event time (SCET)'
  printf,ouf,'//xi,yi,zi,vxi,vyi,vzi: Inertial state in MME 2000,m/s'
  printf,ouf,'//xrel,yrel,zrel,vxrel,vyrel,vzrel: Mars rotating relative state in IAU_MARS'
  printf,ouf,'//gt,gw,gn: Non-gravitational acceleration in T,W,N frame, m/s^2"
  printf,ouf,'//Lat is geodetic latitude in degrees, positive is north"'
  printf,ouf,'//Lon is longitude in degrees, positive is east"'
  printf,ouf,'//Altitude above ellipsoid, m"'
  printf,ouf,'//Airspeed is magnitude of relative velocity vector, so speed relative to calm atmosphere"'
  printf,ouf,format='(%"array[%d][20] {")',n_elements(tt)
  for i=0,n_elements(tt)-1 do begin
    
    printf,ouf,string(format='(%"{%8.3f,'+ $
                                '%12.3f,%12.3f,%12.3f,%12.6f,%12.6f,%12.6f,'+ $ inertial state
                                '%12.3f,%12.3f,%12.3f,%12.6f,%12.6f,%12.6f,'+ $ Mars rotating relative state
                                '%12.6f,%12.6f,%12.6f,'+ $ Drag in TWN frame
                                '%12.6f,%12.6f,%12.3f,%12.6f,%12.6f},")', $ lat,lon,alt,airspd
                                tt[i]-tt[0], $
                                ri[0,i],ri[1,i],ri[2,i],vi[0,i],vi[1,i],vi[2,i],$
                                rrel[0,i],rrel[1,i],rrel[2,i],vrel[0,i],vrel[1,i],vrel[2,i],$
                                gi_drag[0,i],gi_drag[1,i],gi_drag[2,i], $                         
                                lla[0,i]*180d/!dpi,lla[1,i]*180d/!dpi,lla[2,i]*1000d,airspd[i])
  end
  close,ouf
  free_lun,ouf
end
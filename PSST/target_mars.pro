pro target_mars,t0,t1,t_l,t=t,x=x,ret=ret
  t0='2011 NOV 25 17:00:00 TDB' ;Time of beginning of MSL spice kernel
  t1='2012 AUG 06 05:17:07 TDB' ;Time of periapse of approach hyperbola
  t_l='2011 NOV 25 15:25:00 UTC'; Launch time of MSL
  dt_edl=403d; 
  tau=!dpi*2d ;Tau manifesto
  dlm_register,'C:\Users\jeppesen\IDLWorkspace80\icy\lib\icy.dlm'
  print,cspice_tkvrsn('TOOLKIT')
  cspice_furnsh,'generic.tm'
  cspice_furnsh,'msl.tm'
  cspice_str2et,t0,et0
  cspice_str2et,t1,et1  
  cspice_str2et,t_l,et_l  
  
  cspice_spkezr,'EARTH',et0,'J2000','NONE','SUN',s0,ltime
  cspice_spkezr,'MARS' ,et1,'J2000','NONE','SUN',s1,ltime
  print,"heliocentric depart et,state",et0,s0
  print,"heliocentric arrive et,state",et1,s1
  ;Don't fight it, keep things in km,s for at least cruise
  cspice_gdpool,'BODY10_GM',0,1,gm_sun,found
  cspice_gdpool,'BODY4_GM',0,1,gm_mars,found
  cspice_gdpool,'AU',0,1,au,found
  gm_sun=gm_sun[0]
  gm_mars=gm_mars[0]
  au=au[0]
  print,"gm_sun,au,gm_mars",gm_sun,au,gm_mars
  bmw_gauss,s0[0:2],s1[0:2],et1-et0,vv1=v0,vv2=v1,l_du=au,mu=gm_sun
  dv0=v0-s0[3:5]
  dv1=v1-s1[3:5]
  c3=dotp(dv0,dv0)
  print,"C3 depart",c3
  vinf=vlength(dv1)
  print,"Vinf arrive",vinf
  
  target_ei=3522.200d
  target_l= 3396.789d
  target_fpa=-!dtor*15.5d
  
  b=b_from_ei(gm_mars,target_ei,target_fpa,v_inf=vinf,v_ei=v_ei,ta_inf=ta_inf,ta_ei=ta_ei,dt=dt,rp=rp)
  print,"b,vei,dt,rp",b,v_ei,dt,rp
  et_ei=et1+dt
  et_land=et_ei+dt_edl
  cspice_et2utc,et_ei,"ISOC",3,cal_ei
  print,"EI time:",cal_ei,"UTC"  
  cspice_et2utc,et_land,"ISOC",3,cal_land
  print,"Land time:",cal_land,"UTC"  
  ;planetocentric planet-relative unit vector parallel to incoming asymptote
  ;Vectors are in J2000 frame
  sh=normalize_grid(dv1)
  ;North reference vector - happens to be parallel to J2000 Z axis (~Earth north pole)
  nh=[0d,0d,1d]
  ;East vector T - perpendicular to S, and therefore on B-plane. 
  ;                perpendicular to N, and therefore pointing east.
  th=normalize_grid(crossp_grid(sh,nh))
  ;South vector R - perpendicular to S, and therefore on B-plane.
  ;                 perpendicular to T, and therefore pointing south.
  rh=normalize_grid(crossp_grid(sh,th))
  ta_b=-ta_inf-tau/4d
  sig_ei=ta_b+ta_ei
  sig_l=sig_ei+(705d/3396d) ;travel about 12.5deg during EDL
  s_l=sin(sig_l)
  c_l=cos(sig_l)
  s_ei=sin(sig_ei)
  c_ei=cos(sig_ei)
    
  print,"ta_b,sig_ei,sig_l",ta_b*!radeg,sig_ei*!radeg,sig_l*!radeg
  
  q0=5.82d;2345d
  q1=5.826d
  ;q=dindgen(628)/628d*(q1-q0)+q0
  q=q1
  s_q=sin(q)
  c_q=cos(q)
  l_locus_j2000_l=dblarr(n_elements(q),3)
  l_locus_mars_l=dblarr(n_elements(q),3)
  l_latlon_mars_l=dblarr(n_elements(q),2)
  l_locus_j2000_ei=dblarr(n_elements(q),3)
  l_locus_mars_ei=dblarr(n_elements(q),3)
  l_latlon_mars_ei=dblarr(n_elements(q),2)
  cspice_tipbod,'J2000',499,et_land,tipm_l
  cspice_tipbod,'J2000',499,et_ei,tipm_ei
  for i=0,n_elements(q)-1 do begin
    l_locus_j2000_l[i,*]=target_l*(sh*s_l+th*c_q[i]*c_l+rh*s_q[i]*c_l)
    l_locus_mars_l[i,*]=tipm_l ## transpose(l_locus_j2000_l[i,*]) 
    l_locus_j2000_ei[i,*]=target_ei*(sh*s_ei+th*c_q[i]*c_ei+rh*s_q[i]*c_ei)
    l_locus_mars_ei[i,*]=tipm_ei ## transpose(l_locus_j2000_ei[i,*]) 
  end
  Bv=b*(th*c_q[0]+rh*s_q[0])
  print,"B vector, J2000",Bv
  l_latlon_mars_l[*,0]=asin(l_locus_mars_l[*,2]/target_l)
  l_latlon_mars_l[*,1]=atan(l_locus_mars_l[*,1],l_locus_mars_l[*,0])
  l_latlon_mars_ei[*,0]=asin(l_locus_mars_ei[*,2]/target_ei)
  l_latlon_mars_ei[*,1]=atan(l_locus_mars_ei[*,1],l_locus_mars_ei[*,0])
  gale_lat=-4.49
  gale_lon=137.42
  plot,l_latlon_mars_l[*,1]*!radeg,l_latlon_mars_l[*,0]*!radeg,xrange=[-2d,1]*10+gale_lon,yrange=[-1d,1]*10+gale_lat, /xs,/ys
  oplot,[1d,1]*gale_lon,[1d,1]*gale_lat,psym=1
  oplot,l_latlon_mars_l[*,1]*!radeg,l_latlon_mars_l[*,0]*!radeg,color=254,psym=1
  oplot,l_latlon_mars_ei[*,1]*!radeg,l_latlon_mars_ei[*,0]*!radeg,color=64,psym=1
  rv_ei=l_locus_j2000_ei[0,*]
  rh_ei=normalize_grid(rv_ei[0,*])
  nh_ei=normalize_grid(crossp_grid(Bv,rh_ei))
  qh_ei=normalize_grid(crossp_grid(nh_ei,rh_ei))
  vv_ei=v_ei*(rh_ei*sin(target_fpa)+qh_ei*cos(target_fpa))
  sv_ei=[rv_ei[*],vv_ei[*]]
  print,'Entry state, J2000 ',sv_ei
  cspice_sxform,'J2000','MARSIAU',et_ei,sxform
  sv_ei_mi=transpose(sxform ## sv_ei)
  print,'Entry pos, Mars IAU',sv_ei_mi
  llr_target=[gale_lat,gale_lon,0d]*!dtor+[0,0,3396000d]
  rvrel_target=llr_to_xyz(llr_target)
  integrate_edl,sv_ei_mi*1000d,et_ei,rvrel_target,tt=t,x=x,ret=ret
  plot,[ret[*].llr[1]*!radeg,gale_lon],[ret[*].llr[0]*!radeg,gale_lat],/iso,/nodata
  oplot,ret[*].llr[1]*!radeg,ret[*].llr[0]*!radeg
  oplot,ret[0:*:240].llr[1]*!radeg,ret[0:*:240].llr[0]*!radeg,psym=-1
  oplot,[1d,1]*gale_lon,[1d,1]*gale_lat,psym=1,color=192
  
  gpx,'c:\users\jeppesen\Desktop\msl.gpx',ret,t,et_ei
end
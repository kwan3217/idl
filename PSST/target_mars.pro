pro target_mars,t0,t1,t_l
  tau=!dpi*2d ;Tau manifesto
  dlm_register,'C:\Users\jeppesen\IDLWorkspace80\icy\lib\icy.dlm'
  print,cspice_tkvrsn('TOOLKIT')
  cspice_furnsh,'generic.tf'
  cspice_furnsh,'msl.tf'
  cspice_str2et,t0,et0
  cspice_str2et,t1,et1  
  cspice_str2et,t_l,et_l  
  
  cspice_spkezr,'EARTH',et0,'J2000','NONE','SUN',s0,ltime
  cspice_spkezr,'MARS' ,et1,'J2000','NONE','SUN',s1,ltime
  cspice_spkezr,'MSL'  ,et0,'J2000','NONE','EARTH',msl0,ltime
  print,"heliocentric depart et,state",et0,s0
  print,"heliocentric arrive et,state",et1,s1
  print,"geocentric depart et,state",et0,msl0
  ;Don't fight it, keep things in km,s for at least cruise
  cspice_gdpool,'BODY10_GM',0,1,gm_sun,found
  cspice_gdpool,'BODY4_GM',0,1,gm_mars,found
  cspice_gdpool,'BODY399_GM',0,1,gm_earth,found
  cspice_gdpool,'AU',0,1,au,found
  gm_sun=gm_sun[0]
  gm_mars=gm_mars[0]
  gm_earth=gm_earth[0]
  au=au[0]
  dep_elorb=elorb(msl0[0:2],msl0[3:5],6378.137d,gm_earth)
  help,dep_elorb,/str
  et_dep=et0-dep_elorb.tp
  cspice_et2utc,et_dep,"ISOC",3,cal_dep
  print,"dep_time:",cal_dep
  print,"gm_sun,au,gm_mars,gm_earth",gm_sun,au,gm_mars,gm_earth
  gauss,s0[0:2],s1[0:2],et1-et0,vv1=v0,vv2=v1,l_du=au,mu=gm_sun
  dv0=v0-s0[3:5]
  dv1=v1-s1[3:5]
  c3=dotp(dv0,dv0)
  print,"C3 depart",c3
  vinf=vlength(dv1)
  print,"Vinf arrive",vinf
  
  target_ei=3522.200d
  target_l= 3396.789d
  target_fpa=-!dtor*15.5d
  
  b=b_from_ei(gm_mars,target_ei,target_fpa,v_inf=vinf,v_ei=vei,ta_inf=ta_inf,ta_ei=ta_ei)
  print,"b,vei",b,vei
  
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
  sig_l=sig_ei+!dtor*12.2563 ;travel about 12.5deg during EDL
  s_l=sin(sig_l)
  c_l=cos(sig_l)
    
  print,"ta_b,sig_ei,sig_l",ta_b*!radeg,sig_ei*!radeg,sig_l*!radeg
  
  q=dindgen(628)/100d
  s_q=sin(q)
  c_q=cos(q)
  l_locus_j2000=dblarr(n_elements(q),3)
  l_locus_mars=dblarr(n_elements(q),3)
  l_latlon_mars=dblarr(n_elements(q),2)
  cspice_tipbod,'J2000',499,et1,tipm
  for i=0,n_elements(q)-1 do begin
    l_locus_j2000[i,*]=target_l*(sh*s_l+th*c_q[i]*c_l+rh*s_q[i]*c_l)
    l_locus_mars[i,*]=tipm ## transpose(l_locus_j2000[i,*]) 
  end
  l_latlon_mars[*,0]=asin(l_locus_mars[*,2]/target_l)
  l_latlon_mars[*,1]=atan(l_locus_mars[*,1],l_locus_mars[*,0])
  gale_lat=-4.49
  gale_lon=137.42
  plot,l_latlon_mars[*,1]*!radeg,l_latlon_mars[*,0]*!radeg,xrange=[-180,180],yrange=[-90,90], /xs,/ys
  plots,l_latlon_mars[*,1]*!radeg,l_latlon_mars[*,0]*!radeg,color=dindgen(n_elements(q))*256/n_elements(q)
  oplot,[1d,1]*gale_lon,[1d,1]*gale_lat,psym=1
  
  pad41_lat=28.583448d*tau/360d
  pad41_lon=-80.582873d*tau/360d
  
  dec_dv0 = asin(dv0[2]/sqrt(total(dv0^2)))
  ra_dv0=atan(dv0[1],dv0[0])
  
  print,"ra,dec vinf depart",!radeg*ra_dv0,!radeg*dec_dv0
  
  earth_surf_r=6378.137d
  earth_dep_r=earth_surf_r +185d
  vinf_dep=sqrt(c3)
  a_dep=-gm_earth/(vinf_dep^2)
  e=1d -earth_dep_r/a_dep
  ta_inf_dep=acos(-1d/e)
  
  lh_launch_earth=[cos(pad41_lon)*cos(pad41_lat),sin(pad41_lon)*cos(pad41_lat),sin(pad41_lat)]
  cspice_tipbod,'J2000',399,et_l,tipe
  lh_launch_j2000=transpose(tipe) ## transpose(lh_launch_earth)
  
  print,vinf_dep,a_dep,e,!radeg*ta_inf_dep
end
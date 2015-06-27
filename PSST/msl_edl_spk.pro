pro msl_edl_spk
  tic
  tau=2d*!dpi ; tau manifesto
  t0='2012 Aug 6 00:00:00.000TDB'
  caldat,systime(/utc,/jul),mon,day,yr,hr,mn,sec
  t1='2012 Aug 6 05:29:03.000TDB'
;  t1_att='2012 Aug 6 05:29:03.000TDB'
  dlm_register,'C:\Users\jeppesen\IDLWorkspace80\icy\lib\icy.dlm'
  cspice_furnsh,'generic.tm'
  cspice_furnsh,'msl_od137.tm'
  cspice_str2et,t0,et0
  cspice_str2et,t1,et1

  dt=0.1d
  tr0=et0
  tr1=et1
  t=dindgen((tr1-tr0)/dt)*dt+tr0
  ;Entire MSL trajectory at dt interval
  cspice_spkezr,'MSL'  ,t,   'J2000','NONE','499',msl_sv,ltime
  toc,"Done with MSL spice"
  msl_sv=transpose(temporary(msl_sv))
  msl_rv=msl_sv[*,0:2]
  msl_vv=msl_sv[*,3:5]
  msl_av=(shift(msl_vv,-1,0)-msl_vv)/dt
  msl_av[0,*]=0
  msl_av[n_elements(t)-1,*]=0
  
  junk=min(vlength(msl_rv),i_msl_p)
  dist_from_ei=abs(vlength(msl_rv[0:i_msl_p,*])-3522.2)
  junk=min(dist_from_ei,i_msl_ei)
  print,i_msl_ei
  print
  et_ei=t[i_msl_ei]
  cspice_et2utc,et_ei,"ISOC",3,cal_ei
  print,"EI time:",cal_ei,"UTC"  

  mars=obj_new('planet_mars','IAU_MARS')
  t0_spk=et_ei
  t1_spk=et1
  fps=24d
  t_spk=dindgen((t1_spk-t0_spk)*fps)/fps
  ret=make_array(n_elements(t_spk),value={llr:[0d,0,0],alt:0d,dhat:[0d,0,0],lhat:[0d,0,0],yhat:[0d,0,0],arel:[0d,0,0],aair:[0d,0,0],fpa:0d,az:0d,q:0d})
  cspice_spkezr,'MSL'  ,t_spk+et_ei,   'MARSIAU', 'NONE','499',si,ltime    ;Mars centered inertial
  cspice_spkezr,'MSL'  ,t_spk+et_ei,   'IAU_MARS','NONE','499',srel,ltime ;Mars body fixed
 ; cspice_pxform,'MSL_ROVER','IAU_MARS',t_spk+et_ei,pxform_att
  ri=transpose(si[0:2,*])*1000d
  vi=transpose(si[3:5,*])*1000d
  ;total acceleration by numerical differentiation of inertial velocity
  atot=vi*0d
  atot[*,0]=numdif(t_spk,vi[*,0])
  atot[*,1]=numdif(t_spk,vi[*,1])
  atot[*,2]=numdif(t_spk,vi[*,2])
  ;non-gravitational acceleration
  ai=atot-mars.twobody(ri)-mars.j2grav(ri)
  rrel=transpose(srel[0:2,*])*1000d
  vrel=transpose(srel[3:5,*])*1000d
  arel=rrel*0d
  ret.llr=transpose(xyz_to_llr(rrel))
  for i=0,n_elements(t_spk)-1 do begin
    cspice_pxform,'MARSIAU','IAU_MARS',t_spk[i]+et_ei,pxform
    arel[i,*]=pxform ## ai[i,*]
  end
  ret.dhat=transpose(normalize_grid(vrel))
  ret.yhat=transpose(normalize_grid(crossp_grid(rrel,vrel)))
  ret.lhat=transpose(normalize_grid(crossp_grid(transpose(ret.dhat),transpose(ret.yhat))))
  east=normalize_grid(crossp_grid([0,0,1],rrel))
  north=normalize_grid(crossp_grid(rrel,east))
  ret.az=atan(dotp(vrel,east),dotp(vrel,north))
  w=where(ret.az lt 0,count)
  if count gt 0 then ret[w].az+=tau
  drag=dotp(arel,transpose(ret.dhat))
  lift=dotp(arel,transpose(ret.lhat))
  side=dotp(arel,transpose(ret.yhat))
  aair=compose_grid(drag,lift,side)
  ld=-sqrt(lift^2+side^2)/drag ;l/d is positive
  bank=atan(side,lift)
  alpha=ld*0d
  mars->atm,rrel,/is_rel,t=temp,p=p,rho=rho,csound=csound,m=m,alt=alt,llr=llr,agl=agl
  ret.alt=alt
  msl_aero,aero_alpha,aero_mach,aero_cl,aero_cd,aero_ld
  mach=vlength(vrel)/csound
  for i=0,n_elements(alpha)-1 do begin
    alpha_mach=dblarr(n_elements(aero_alpha))
    for j=0,n_elements(aero_alpha)-1 do alpha_mach[j]=-interpol(aero_ld[j,*],aero_mach,mach[i])
    alpha[i]=-interpol(aero_alpha,alpha_mach,ld[i])
  end
  ret.aair=transpose(aair)
  ret.fpa=!dpi/2-vangle(vrel,rrel)
  ret.q=dotp(vrel,vrel)*mars.rho(ret.alt)/2d
  gpx,'c:\users\jeppesen\desktop\msl_spk_od137.gpx',ret,t_spk,et_ei
  start_range=fps*360
  stop_range=start_range+60*fps
  eastv=normalize_grid(crossp_grid([0,0,1],rrel[stop_range,*]))
  northv=normalize_grid(crossp_grid(rrel[stop_range,*],eastv))
  upv=normalize_grid(rrel[stop_range,*])
  rrel_land=rrel-rebin(rrel[stop_range,*],size(rrel,/dim))
  east=dotp(rrel_land[start_range:stop_range,*],eastv)
  north=dotp(rrel_land[start_range:stop_range,*],northv)
  up=dotp(rrel_land[start_range:stop_range,*],upv)
  ed=dotp(vrel[start_range:stop_range,*],eastv)
  nd=dotp(vrel[start_range:stop_range,*],northv)
  ud=dotp(vrel[start_range:stop_range,*],upv)
  edd=dotp(arel[start_range:stop_range,*],eastv)
  ndd=dotp(arel[start_range:stop_range,*],northv)
  udd=dotp(arel[start_range:stop_range,*],upv)
  
  w=where(up gt 0.001)
  print,max(w)/fps
  pov,'c:\users\jeppesen\desktop\msl_edl2_od137.inc',t_spk,et_ei,rrel,vrel,arel,rho,alt,agl,csound,alpha,bank,pxform=pxform_att
end
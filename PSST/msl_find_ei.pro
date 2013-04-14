pro msl_find_ei
  tic
  tau=2d*!dpi ; tau manifesto
  t0='2012 Aug 6 00:00:00.000TDB'
  caldat,systime(/utc,/jul),mon,day,yr,hr,mn,sec
  t1='2012 Aug 6 05:20:00.000TDB'
  dlm_register,'C:\Users\jeppesen\IDLWorkspace80\icy\lib\icy.dlm'
  cspice_furnsh,'generic.tm'
  cspice_furnsh,'msl.tm'
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
  junk=min(abs(vlength(msl_rv[0:i_msl_p,*])-3522.2),i_msl_ei)
  print,i_msl_ei
  et_ei=t[i_msl_ei]
  cspice_et2utc,et_ei,"ISOC",3,cal_ei
  print,"EI time:",cal_ei,"UTC"  

  sv_ei=msl_sv[i_msl_ei,*]
  print,'Entry state, J2000 ',sv_ei
  cspice_sxform,'J2000','MARSIAU',et_ei,sxform
  sv_ei_mi=transpose(sxform ## sv_ei)
  print,'Entry pos, Mars IAU',sv_ei_mi
  gale_lat=-4.49
  gale_lon=137.42
  llr_target=[gale_lat,gale_lon,0d]*!dtor+[0,0,3396000d]
  rvrel_target=llr_to_xyz(llr_target)
  integrate_edl,sv_ei_mi*1000d,et_ei,rvrel_target,tt=t,x=x,ret=ret
  plot,[ret[*].llr[1]*!radeg,gale_lon],[ret[*].llr[0]*!radeg,gale_lat],/iso,/nodata
  oplot,ret[*].llr[1]*!radeg,ret[*].llr[0]*!radeg
  oplot,ret[0:*:240].llr[1]*!radeg,ret[0:*:240].llr[0]*!radeg,psym=-1
  oplot,[1d,1]*gale_lon,[1d,1]*gale_lat,psym=1,color=192
  
  gpx,'c:\users\jeppesen\Desktop\msl.gpx',ret,t,et_ei
  
  t0_spk=et_ei
  t1_spk=et1
  fps=24d
  t_spk=dindgen((t1_spk-t0_spk)*fps)/fps
  cspice_spkezr,'MSL'  ,t_spk+et_ei,   'IAU_MARS','NONE','499',msl_spk_edl,ltime
  msl_spk_edl_r=transpose(msl_spk_edl[0:2,*])*1000d
  msl_spk_edl_v=transpose(msl_spk_edl[3:5,*])*1000d
  ret_edl_spk=make_array(n_elements(t_spk),value={llr:[0d,0,0],alt:0d,dhat:[0d,0,0],lhat:[0d,0,0],yhat:[0d,0,0],vrel:0d,arel:[0d,0,0],aair:[0d,0,0]})
  ret_edl_spk.llr=transpose(xyz_to_llr(msl_spk_edl_r))
  mars=obj_new('planet_mars','IAU_MARS')
  for i=0,n_elements(t_spk)-1 do begin
    ret_edl_spk[i].alt=ret_edl_spk[i].llr[2]-mars.equipotential(ret_edl_spk[i].llr,/l)
  end
  dvrel=msl_spk_edl_v-shift(msl_spk_edl_v,1,0)
  dvrel[0,*]=dvrel[1,*]
  arel=dvrel*fps
  arel=arel-mars.twobody(msl_spk_edl_r)-mars.j2grav(msl_spk_edl_r)
  stop
  ret_edl_spk.dhat=transpose(normalize_grid(msl_spk_edl_v))
  ret_edl_spk.yhat=transpose(normalize_grid(crossp_grid(msl_spk_edl_r,msl_spk_edl_v)))
  ret_edl_spk.lhat=transpose(normalize_grid(crossp_grid(transpose(ret_edl_spk.dhat),transpose(ret_edl_spk.yhat))))
  gpx,'c:\users\jeppesen\desktop\msl_spk.gpx',ret_edl_spk,t_spk,et_ei
  stop  
end
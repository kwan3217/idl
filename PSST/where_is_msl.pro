pro where_is_msl
  tic
  tau=2d*!dpi ; tau manifesto
  t0='2011 Nov 26 15:53:00.000TDB'
  caldat,systime(/utc,/jul),mon,day,yr,hr,mn,sec
  t1=string(format='(%"%04d-%02d-%02d %02d:%02d:%06.3fUTC")',yr,mon,day,hr,mn,sec)
  ;TCM1
  t_tcm0='2011 DEC 12 16:00:00 TDB'
  t_tcm1='2011 DEC 12 20:00:00 TDB'
  ;TCM2
  ;t_tcm0='2012 MAR 25 17:00:00 TDB'
  ;t_tcm1='2012 MAR 25 19:00:00 TDB'
  ;TCM3
  ;t_tcm0='2012 JUN 07 17:00:00 TDB'
  ;t_tcm1='2012 JUN 07 19:00:00 TDB'
  dlm_register,'C:\Users\jeppesen\IDLWorkspace80\icy\lib\icy.dlm'
  cspice_furnsh,'generic.tm'
  cspice_furnsh,'msl_od137.tm'
  cspice_str2et,t0,et0
  cspice_str2et,t1,et1
  cspice_str2et,t_tcm0,et_tcm0  
  cspice_str2et,t_tcm1,et_tcm1  

  dt=60d
  tr0=et0
  tr1=et1
  t=dindgen((tr1-tr0)/dt)*dt+tr0
  ;Entire MSL trajectory at dt interval
  cspice_spkezr,'MSL'  ,t,   'J2000','NONE','399',msl_sv,ltime
  cspice_spkezr,'301'  ,t,   'J2000','NONE','399',moon_sv,ltime
  toc,"Done with MSL spice"
  msl_sv=transpose(temporary(msl_sv))
  msl_rv=msl_sv[*,0:2]
  msl_vv=msl_sv[*,3:5]
  msl_av=(shift(msl_vv,-1,0)-msl_vv)/dt
  msl_av[0,*]=0
  msl_av[n_elements(t)-1,*]=0

  moon_sv=transpose(temporary(moon_sv))
  moon_rv=moon_sv[*,0:2]
  moon_vv=moon_sv[*,3:5]
  plot,msl_rv[*,0],msl_rv[*,1],/iso,xrange=[-1.2d6,1.2d6],yrange=[-1.2d6,1.2d6]
  oplot,cos(dindgen(628)*0.01)*6378.137,sin(dindgen(628)*0.01)*6378.137
  oplot,moon_rv[*,0],moon_rv[*,1]
stop
  ;five point stencil numerical derivative of MSL trajectory
  fp=[dblarr(2,6)*!values.f_nan,(-msl_sv[4:n_elements(t)-1,*]+8d*msl_sv[3:n_elements(t)-2,*]-8d*msl_sv[1:n_elements(t)-4,*]+msl_sv[0:n_elements(t)-5,*])/(12d*dt),dblarr(2,6)*!values.f_nan]
  
  for i=0,n_elements(body)-1 do begin
    cspice_spkezr,string(body[i]),t,'J2000','NONE','SSB',body_sv,ltime
    toc,"Done with body spice "+string(body[i])
    body_sv=transpose(temporary(body_sv))
    body_rv=msl_rv-body_sv[*,0:2]
    body_r3=rebin(vlength(body_rv)^3d,n_elements(t),3)
    a_grav-=mu[i]*body_rv/body_r3
    if(i eq 0) then begin
      ;TSI is 1361W/m^2
      ;c is 299792458m/s
      ;ok that units are in m/s
      body_au=body_rv/au
      body_a3=rebin(vlength(body_au)^3d,n_elements(t),3)
      ;pressure in N/m^2
      p_srp=1361d/299792458d *body_au/body_a3
      ;cruise stage area in m^2
      ;a_msl=tau*(4.5d/2d)^2/2d
      a_msl=0d
      ;force in N
      F_srp=p_srp*a_msl
      ;cruise mass in kg (no prop used)
      m_msl=3893d
      ;acceleration in km/s
      a_srp=(f_srp/m_msl)/1000d
      a_grav+=a_srp    
    end
  end
  
  x0=msl_rv[*,0]
  y0=msl_rv[*,1]
  
  x1=fp[*,3+0]-a_grav[*,0]
  y1=fp[*,3+1]-a_grav[*,1]
  
  plot,[0,0],xrange=[-3d8,3d8],yrange=[-3d8,3d8],/iso
  for i=0,n_elements(x0)-1,500000/dt do begin
    oplot,[x0[i],x0[i]+3d19*x1[i]],[y0[i],y0[i]+3d19*y1[i]]
  end
  
  t_dif=t[i_tcm1+5:n_elements(t)-1]
  msl_int_posttcm1=kwan_rk4(msl_sv[i_tcm1+5,*],t[i_tcm1+5:n_elements(t)-1],'f_mslint',body_code=body,body_mu=mu)
  msl_sv_dif=msl_int_posttcm1-msl_sv[i_tcm1+5:n_elements(t)-1,*]
  toc,"Done with post-tcm1 integration"
  stop
  msl_int_pretcm1= kwan_rk4(msl_sv[i_tcm1-5,*],t[i_tcm1-5:n_elements(t)-1],'f_mslint',body_code=body,body_mu=mu)
  toc,"Done with pre-tcm1 integration"
  
  stop  
end
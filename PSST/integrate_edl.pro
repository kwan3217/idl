function msl_chute_mef,M
  if n_elements(M) le 1 then result=0d else result=dblarr(size(M,/dim))
  w=where(M le 0.7d,count)
  if count gt 0 then result[w]=1.00d
  w=where(M gt 0.7d and M le 0.94d,count)
  if count gt 0 then result[w]=linterp(0.7d,1.0d,0.94d,0.67d,M[w])
  w=where(M gt 0.94d and M le 1.4d,count)
  if count gt 0 then result[w]=1-0.33d*linterp(0.94d,1d,1.4d,0d,M[w])^2
  w=where(M gt 1.4d and M le 1.85d,count)
  if count gt 0 then result[w]=1-0.16d*linterp(1.4d,0d,1.85d,1d,M[w])^2
  w=where(M gt 1.85d,count)
  if count gt 0 then result[w]=linterp(1.85d,0.84,2.6d,0.61d,M[w])
  return,result
end  

function f_bank,vrel
  tau=!dpi*2d ; tau manifesto
  if(vrel lt 1100) then return,8*tau/360d
  if(vrel lt 2850) then return,42*tau/360d
  return,linterp(2850d,42d,5400d,65d,vrel)*tau/360d
end

function f_c,vrel,mach,bank,alpha=alpha,ld=ld
  ;drag coefficient, negative in most cases since drag basis vector points forward
  ;side coefficient, positive to the left of the vehicle vertical plane
  ;lift coefficient, positive up
  common f_c_static,aero_alpha,aero_mach,aero_cl,aero_cd,aero_cm,aero_ld
  if n_elements(aero_alpha) eq 0 then msl_aero,aero_alpha,aero_mach,aero_cl,aero_cd,aero_ld
  alpha_mach=dblarr(n_elements(aero_alpha))
  for i=0,n_elements(aero_alpha)-1 do alpha_mach[i]=-interpol(aero_ld[i,*],aero_mach,mach)
  ld=linterp(500d,0.31,5000d,0.24,vrel)
  if(vrel lt 500) then ld=0d
  alpha=-interpol(aero_alpha,alpha_mach,ld)
  cd=tableterp(aero_cd,aero_alpha,aero_mach,-alpha,mach)
  return,[-1d,ld*sin(bank),ld*cos(bank)]*cd 
end

function f_edl,t,x,ret=ret,delta_d=delta_d,loaded=loaded,et0=et0,rvrel_target=rvrel_target
  sv=x[0:5]
  rv=sv[0:2]
  vv=sv[3:5]
  roll=x[6]
  if n_elements(delta_d) eq 0 then delta_d=0
  common f_edl_static,mars,chute_open_time
  tau=!dpi*2d
  
  ;Load common block
  if ~keyword_set(loaded) then begin
    loaded=1
    chute_open_time=-1d
    if n_elements(mars) eq 0 || ~obj_valid(mars) then begin
      dlm_register,'..\icy\lib\icy.dlm'
      cspice_furnsh,'generic.tm'
      mars=obj_new('planet_mars','MARSIAU')
    end
  end
  
  ;Two-body acceleration
  a_2b=mars->twobody(rv)
  
  ;J2 acceleration
  a_j2=mars->j2grav(rv)
  
  ;Atmospheric frame
  vrelv=vv-mars->wind(rv)
  vrel2=dotp(vrelv,vrelv)
  vrel=sqrt(vrel2)
  dragh=normalize_grid(vrelv)
  sideh=normalize_grid(crossp_grid(rv,vrelv))
  lifth=normalize_grid(crossp_grid(dragh,sideh))
  
  ;Guidance calculations
  cspice_sxform,'MARSIAU','IAU_MARS',t+et0,sxform
  s_rel=sxform ## sv
  downrange_to_go=vangle(s_rel[0:2],rvrel_target)*3396000d
  hh=normalize_grid(crossp_grid(s_rel[0:2],s_rel[3:5]))
  crossrange_to_go=dotp(rvrel_target,hh)
  
  ;Capsule drag acceleration
  mars->atm,rv,t+et0,rho=rho,csound=csound,alt=alt,llr=llr
  q=0.5d*rho*vrel2
  bank=f_bank(vrel)
  if t ge 80 and t lt 90 then begin
    bank=linterp(80d,bank,90d,-bank,t)
  end
  if t ge 90 and t lt 110 then begin
    bank=-bank
  end
  if t ge 110 and t lt 120 then begin
    bank=linterp(110d,-bank,120d,-bank,t)
  end
  if t ge 120 and t lt 140 then begin
    bank=bank
  end
  if t ge 140 and t lt 150 then begin
    bank=linterp(140d,bank,150d,-bank,t)
  end
  if t ge 150 then bank=-bank
  c=f_c(vrel,vrel/csound,-bank,alpha=alpha,ld=ld)
  a_msl=0.5d*tau*2.25d^2d
  f_aero=q*c*a_msl
  m_msl=3300d
  a_aero=f_aero/m_msl
  a_drag=a_aero[0]+delta_d
  a_aero=dragh*a_drag+sideh*a_aero[1]+lifth*a_aero[2]
  
  ;Parachute drag acceleration
  t_sufr=15d ;Straighten up and fly right time
  chute_arm_mach=3.0d
  chute_trigger_mach=2.1d -(a_drag*t_sufr)/csound ;a_drag is negative
  if chute_open_time lt 0 then begin
    if vrel/csound lt min([chute_arm_mach,chute_trigger_mach]) then chute_open_time=t
    a_p=[0d,0,0]
    c_p=0d
    f_p=0d
  end else begin
    line_stretch_v=29.4d ;parachute mortar speed (m/s)
    line_length=33.49d +10.14d +1.37d ;parachute line length (m)
    chute_d0=19.7d ;nominal chute diameter, does not match any actual diameter of the chute
    chute_exp=4d
    chute_infl_v=27.2d ;chute mean inflation speed
    chute_open_lf=1.344d ; chute opening load factor
    chute_s0=0.5d*tau*(chute_d0/2d)^2
    chute_cd0=0.62
    t_ls=chute_open_time+line_length/line_stretch_v+t_sufr
    t_fi=t_ls+chute_d0/chute_infl_v
    if t lt t_ls then begin 
      c_p=0d
    end else begin
      chute_cd=chute_cd0*msl_chute_mef(vrel/csound)
      if t lt t_fi then begin
        c_p=chute_open_lf*((t-t_ls)/(t_fi-t_ls))^chute_exp
      end else begin
        c_p=1d
      end
      c_p=c_p*chute_cd
    end
    f_p=-c_p*q*chute_s0
    a_p=f_p/m_msl
    a_p=dragh*a_p
  end
     
  ret={q:q,vrel:vrel,mach:vrel/csound,alt:alt,bank:bank,c:c,alpha:alpha,ld:ld,a_drag:a_drag,c_p:c_p,a_p:f_p/m_msl,llr:llr, $
       downrange_to_go:downrange_to_go,crossrange_to_go:crossrange_to_go,chute_trigger_mach:chute_trigger_mach,chute_open_time:chute_open_time}
  return,[vv,a_2b+a_j2+a_aero+a_p,0]  
end

pro integrate_edl,x0,et0,rvrel_target,x=x,tt=t,ret=ret,t_delta_d=t_delta_d,range_delta_d=range_delta_d,t_delta_rdot=t_delta_rdot,range_delta_rdot=range_delta_rdot
  tau=!dpi*2d
  if n_elements(x0) eq 0 then begin
    t0='2012 AUG 06 11:30:58.537 TDB'
    dlm_register,'C:\Users\jeppesen\IDLWorkspace80\icy\lib\icy.dlm'
    cspice_furnsh,'generic.tm'
    cspice_furnsh,'msl.tm'
    cspice_str2et,t0,et0

    ;MSL entry state from cruise
    cspice_spkezr,'MSL'  ,et0,   'MARSIAU','NONE','499',x0,ltime
    x0=x0*1000d
  end

  fps=24d
  tmax=450d
  t=dindgen(tmax*fps)/fps
  x_ref=kwan_rk4([x0,0],t,'f_edl',f_c='f_c',ret=ret,et0=et0,rvrel_target=rvrel_target)
  wset,0
  plot,x_ref[*,1]/1000d,x_ref[*,0]/1000d,/ynoz,/iso
  q=dindgen(628)*0.01d
  oplot,3396d*sin(q),3396d*cos(q),color=254
  
;  for j=50,t_dep,5 do begin
;    i=j*24
;    t_per=t[i:n_elements(t_ref)-1]
;    x0_per=x_ref[i,*]
;    delta_rdot=1d
;    delta_d=0
;    x0_per[3:5]+=normalize_grid(x0_per[0:2])*delta_rdot
;    x_per=kwan_rk4(x0_per,t_per,'f_edl',ret=ret_per,delta_d=delta_d)
;    x_per=[x_ref[0:i-1,*],x_per]
;    ret_per=[ret[0:i-1],ret_per]
;    range_per=get_range(x_per,ret_per)
;    print,"Perturbed range: delta_rdot=",delta_rdot,"m/s, t=",t_per[0],", range=",3396000d*range_per     
;    oplot,x_per[*,1]/1000d,x_per[*,0]/1000d,color=255-j
;    wait,0.1
;    if n_elements(t_delta_rdot) eq 0 then t_delta_rdot=t_per[0] else t_delta_rdot=[t_delta_rdot,t_per[0]]
;    if n_elements(range_delta_rdot) eq 0 then range_delta_rdot=range_per else range_delta_rdot=[range_delta_rdot,range_per]
;  end
;  window,2
;  plot,t_delta_rdot,range_delta_rdot*3396000d,/ynoz
;
;  for j=50,t_dep,5 do begin
;    i=j*24
;    t_per=t[i:n_elements(t_ref)-1]
;    x0_per=x_ref[i,*]
;    delta_rdot=0d
;    delta_d=0.1d
;    x0_per[3:5]+=normalize_grid(x0_per[0:2])*delta_rdot
;    x_per=kwan_rk4(x0_per,t_per,'f_edl',ret=ret_per,delta_d=delta_d)
;    x_per=[x_ref[0:i-1,*],x_per]
;    ret_per=[ret[0:i-1],ret_per]
;    range_per=get_range(x_per,ret_per)
;    print,"Perturbed range: delta_d=",delta_d,"m/s^2, t=",t_per[0],", range=",3396000d*range_per     
;    oplot,x_per[*,1]/1000d,x_per[*,0]/1000d,color=255-j
;    wait,0.1
;    if n_elements(t_delta_d) eq 0 then t_delta_d=t_per[0] else t_delta_d=[t_delta_d,t_per[0]]
;    if n_elements(range_delta_d) eq 0 then range_delta_d=range_per else range_delta_d=[range_delta_d,range_per]
;  end
;  window,1
;  plot,t_delta_d,range_delta_d*3396000d,/ynoz
end
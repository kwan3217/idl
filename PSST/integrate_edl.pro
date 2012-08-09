function f_edl,t,x,ret=ret,delta_d=delta_d,loaded=loaded
  
  if n_elements(delta_d) eq 0 then delta_d=0
  common f_edl_static,mars,chute_open_time
  tau=!dpi*2d
  
  ;Load common block
  if ~keyword_set(loaded) then begin
    loaded=1
    chute_open_time=-1
    if n_elements(mars) eq 0 || ~obj_valid(mars) then begin
      dlm_register,'..\icy\lib\icy.dlm'
      cspice_furnsh,'generic.tm'
      mars=obj_new('planet_mars','MARSIAU')
    end
  end
  
  rv=x[0:2]
  vv=x[3:5]
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
  
  ;Capsule drag acceleration
  mars->atm,rv,t,rho=rho,csound=csound,alt=alt,llr=llr
  q=0.5d*rho*vrel2
  bank=f_bank(vrel)
  c=f_c(vrel,vrel/csound,bank,alpha=alpha,ld=ld)
  a_msl=0.5d*tau*2.25d^2d
  f_aero=q*c*a_msl
  m_msl=3300d
  a_aero=f_aero/m_msl
  a_drag=a_aero[0]+delta_d
  a_aero=dragh*a_drag+sideh*a_aero[1]+lifth*a_aero[2]
  
  ;Parachute drag acceleration
  chute_trigger_mach=2.1d
  if chute_open_time lt 0 then begin
    if vrel/csound lt chute_trigger_mach then chute_open_time=t
    a_p=[0d,0,0]
    c_p=0d
    f_p=0d
  end else begin
    line_stretch_v=29.4d ;parachute mortar speed (m/s)
    t_sufr=15d ;Straighten up and fly right time
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
     
  ret={q:q,vrel:vrel,mach:vrel/csound,alt:alt,bank:bank,c:c,alpha:alpha,ld:ld,a_drag:a_drag,c_p:c_p,a_p:f_p/m_msl,llr:llr}
  return,[vv,a_2b+a_j2+a_aero+a_p]  
end

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

pro f_c_load_const
  common f_c_static,aero_alpha,aero_mach,aero_cl,aero_cd,aero_cm,aero_ld
    aero_alpha=[0,  2,  4,  6,  11, 16]*!dtor;
    aero_mach=[ $
     0.4, 0.6, 0.8, 0.9, 1.0, $
     1.2, 1.5, 2.0, 3.0, 4.0, $
     5.0, 6.3, 8.8, 9.8,10.8, $
    11.8,12.8,13.9,15.0,16.0, $
    17.0,18.1,19.2,20.3,21.3, $
    22.4,23.4,24.5,25.5,26.4, $
    27.2,28.0,30.0];

    aero_cl=[ $
    [0, -0.0362,  -0.0729,  -0.1051,  -0.1894,  -0.2672], $
    [0, -0.0382,  -0.0764,  -0.1096,  -0.1955,  -0.2758], $
    [0, -0.0407,  -0.0785,  -0.1172,  -0.2071,  -0.2904], $
    [0, -0.0428,  -0.0850,  -0.1237,  -0.2182,  -0.3066], $
    [0, -0.0519,  -0.0976,  -0.1394,  -0.2389,  -0.3439], $
    [0, -0.0594,  -0.1057,  -0.1480,  -0.2596,  -0.3732], $
    [0, -0.0579,  -0.1062,  -0.1495,  -0.2712,  -0.3955], $
    [0, -0.0503,  -0.1017,  -0.1495,  -0.2692,  -0.3793], $
    [0, -0.0498,  -0.1017,  -0.1500,  -0.2687,  -0.3773], $
    [0, -0.0503,  -0.1027,  -0.1510,  -0.2702,  -0.3732], $
    [0, -0.0503,  -0.1017,  -0.1515,  -0.2712,  -0.3707], $
    [0, -0.0508,  -0.1042,  -0.1535,  -0.2717,  -0.3682], $
    [0, -0.0529,  -0.1062,  -0.1571,  -0.2717,  -0.3621], $
    [0, -0.0524,  -0.1077,  -0.1581,  -0.2717,  -0.3626], $
    [0, -0.0534,  -0.1077,  -0.1586,  -0.2722,  -0.3631], $
    [0, -0.0529,  -0.1093,  -0.1596,  -0.2727,  -0.3621], $
    [0, -0.0539,  -0.1103,  -0.1601,  -0.2722,  -0.3636], $
    [0, -0.0544,  -0.1093,  -0.1611,  -0.2722,  -0.3636], $
    [0, -0.0554,  -0.1113,  -0.1606,  -0.2727,  -0.3641], $
    [0, -0.0569,  -0.1123,  -0.1611,  -0.2717,  -0.3641], $
    [0, -0.0564,  -0.1123,  -0.1611,  -0.2722,  -0.3641], $
    [0, -0.0579,  -0.1118,  -0.1596,  -0.2712,  -0.3636], $
    [0, -0.0569,  -0.1113,  -0.1596,  -0.2717,  -0.3631], $
    [0, -0.0564,  -0.1118,  -0.1586,  -0.2712,  -0.3631], $
    [0, -0.0554,  -0.1093,  -0.1591,  -0.2702,  -0.3626], $
    [0, -0.0544,  -0.1088,  -0.1581,  -0.2717,  -0.3631], $
    [0, -0.0544,  -0.1082,  -0.1586,  -0.2707,  -0.3631], $
    [0, -0.0544,  -0.1082,  -0.1571,  -0.2702,  -0.3621], $
    [0, -0.0534,  -0.1077,  -0.1571,  -0.2702,  -0.3621], $
    [0, -0.0534,  -0.1082,  -0.1566,  -0.2692,  -0.3606], $
    [0, -0.0534,  -0.1082,  -0.1566,  -0.2687,  -0.3616], $
    [0, -0.0544,  -0.1072,  -0.1561,  -0.2692,  -0.3601], $
    [0, -0.0529,  -0.1047,  -0.1530,  -0.2646,  -0.3601]  $
    ];

    aero_cd=[ $
    [1.0441,  1.0464, 1.0453, 1.0398, 1.0311, 1.0112], $
    [1.0943,  1.0949, 1.0903, 1.0926, 1.0779, 1.0562], $ 
    [1.1618,  1.1633, 1.1569, 1.1601, 1.1532, 1.1237], $
    [1.2146,  1.2152, 1.2261, 1.2241, 1.2129, 1.1834], $
    [1.3020,  1.3069, 1.3248, 1.3236, 1.3124, 1.3046], $
    [1.4136,  1.4263, 1.4260, 1.4248, 1.4214, 1.4041], $
    [1.5356,  1.5457, 1.5454, 1.5408, 1.5313, 1.5114], $
    [1.5702,  1.5691, 1.5662, 1.5546, 1.5183, 1.4621], $
    [1.5763,  1.5751, 1.5714, 1.5616, 1.5174, 1.4499], $
    [1.5849,  1.5838, 1.5774, 1.5685, 1.5218, 1.4439], $
    [1.5962,  1.5950, 1.5869, 1.5771, 1.5261, 1.4404], $
    [1.6074,  1.6045, 1.5982, 1.5875, 1.5330, 1.4352], $
    [1.6273,  1.6253, 1.6155, 1.6040, 1.5373, 1.4335], $
    [1.6351,  1.6331, 1.6259, 1.6143, 1.5391, 1.4378], $
    [1.6420,  1.6409, 1.6321, 1.6187, 1.5443, 1.4387], $
    [1.6481,  1.6469, 1.6397, 1.6247, 1.5477, 1.4413], $
    [1.6541,  1.6521, 1.6458, 1.6299, 1.5486, 1.4430], $
    [1.6619,  1.6582, 1.6518, 1.6342, 1.5520, 1.4456], $
    [1.6732,  1.6712, 1.6587, 1.6420, 1.5555, 1.4499], $
    [1.6853,  1.6824, 1.6717, 1.6472, 1.5590, 1.4534], $
    [1.6965,  1.6937, 1.6769, 1.6515, 1.5624, 1.4551], $
    [1.7078,  1.7015, 1.6830, 1.6533, 1.5633, 1.4586], $
    [1.7182,  1.7092, 1.6856, 1.6567, 1.5667, 1.4603], $
    [1.7260,  1.7136, 1.6890, 1.6602, 1.5693, 1.4595], $
    [1.7277,  1.7153, 1.6908, 1.6611, 1.5702, 1.4612], $
    [1.7277,  1.7170, 1.6916, 1.6645, 1.5719, 1.4612], $
    [1.7268,  1.7179, 1.6942, 1.6645, 1.5702, 1.4629], $
    [1.7260,  1.7170, 1.6951, 1.6654, 1.5719, 1.4612], $
    [1.7268,  1.7179, 1.6960, 1.6663, 1.5711, 1.4612], $
    [1.7260,  1.7170, 1.6934, 1.6645, 1.5711, 1.4612], $
    [1.7260,  1.7170, 1.6925, 1.6645, 1.5711, 1.4603], $
    [1.7242,  1.7136, 1.6925, 1.6628, 1.5711, 1.4585], $
    [1.7026,  1.6954, 1.7011, 1.6619, 1.5702, 1.4500] $
    ];
    aero_ld=aero_cl/aero_cd 
end

function f_c,vrel,mach,bank,alpha=alpha,ld=ld
  ;drag coefficient, negative in most cases since drag basis vector points forward
  ;side coefficient, positive to the left of the vehicle vertical plane
  ;lift coefficient, positive up
  common f_c_static,aero_alpha,aero_mach,aero_cl,aero_cd,aero_cm,aero_ld
  if n_elements(aero_alpha) eq 0 then f_c_load_const
  alpha_mach=dblarr(n_elements(aero_alpha))
  for i=0,n_elements(aero_alpha)-1 do alpha_mach[i]=-interpol(aero_ld[i,*],aero_mach,mach)
  ld=linterp(500d,0.31,5000d,0.24,vrel)
  if(vrel lt 500) then ld=0d
  alpha=-interpol(aero_alpha,alpha_mach,ld)
  cd=tableterp(aero_cd,aero_alpha,aero_mach,-alpha,mach)
  return,[-1d,ld*sin(bank),ld*cos(bank)]*cd 
end

function get_range,x_ref,ret,w=w
  R_dep=9000d/3396000d; R_dep in radians
  h_dep=11000d;    Parachute deploy considered to happen at this aeroid alt
  w=min(where(ret.alt lt h_dep))
  return,vangle(x_ref[0,0:2],x_ref[w,0:2])+r_dep
end

pro integrate_edl,x=x,tt=t,ret=ret,t_delta_d=t_delta_d,range_delta_d=range_delta_d,t_delta_rdot=t_delta_rdot,range_delta_rdot=range_delta_rdot
  tau=!dpi*2d
  rv0=[3522200d,0,0]
  fpa0=-15.5d*tau/360d
  v0=6000d
  vv0=[sin(fpa0),cos(fpa0),0d]*v0
  x0=[rv0,vv0]
  fps=24d
  tmax=450d
  t=dindgen(tmax*fps)/fps
  junk=temporary(ret)
  junk=0  
  x_ref=kwan_rk4(x0,t,'f_edl',f_c='f_c',ret=ret)
  range_ref=get_range(x_ref,ret,w=w)
  t_dep=t[w]
  print,"Reference range: ",range_ref*3396000d
  print,"t_dep: ",t_dep
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
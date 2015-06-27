function g_rocketometer,t,x 
  r=x[0:2]
  v=x[3:5]
  a=x[6:8]
  q=x[9:12]
  w=x[13:15]
  a=a-grav(r) ;non-grav acceleration in reference frame
  a=quat_vect_mult(q,a) 
  a_dn=a*32768/160
;  a_dn+=randomn(seed,n_elements(a_dn))*11
;  a_dn=a_dn>(-32768)<(32767)
;  a_dn=fix(a_dn)

;local topocentric system
  lla=xyz_to_lla(r)
  
  z=llr_to_xyz([lla[0],lla[1],1])
  e=normalize_grid(crossp_grid([0d,0,1],z))
  n=normalize_grid(crossp_grid(z,e))
;magnetic field in local system
  b_ned=wmm2010(lla,2013.8)*1d-9*1d4 ;convert from nanoTesla to Gauss  
  b_i=b_ned[0]*n+b_ned[1]*e-b_ned[2]*z
  b_dn=quat_vect_mult(q,b_i)*1090; Rocketometer runs at HMC5883L gain setting 1, 1090DN/Gauss
; b_dn=dblarr(3)
;body frame rotation rate  
  g_dn=w*32768/(2000*!dtor)
  return,transpose([a_dn[*],b_dn[*],g_dn[*]]) ;accelerometer measurement
end


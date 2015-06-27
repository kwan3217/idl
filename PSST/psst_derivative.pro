;fps should not appear here
function psst_derivative,state_i,et,ststus=status
  ;Calculate air-relative state and break states up into position and velocity
  s_i=transpose(state_i[0:5])
  r_i=transpose(state_i[0:2])
  v_i=transpose(state_i[3:5])
  ei2b=transpose(state_i[6:9])
  w_b=transpose(state_i[10:12])
  cspice_sxform,'PHX_MME_2000','IAU_MARS',et,Msmme2iau
  Mrmme2iau=Msmme2iau[0:2,0:2]
  s_rel=Msmme2iau ## s_i
  r_rel=transpose(s_rel[0:2])
  v_rel=transpose(s_rel[3:5])
  a_i=transpose([0d,0,0])
  N_b=transpose([0d,0,0])
  llr=xyz_to_llr(r_rel)
  aclat=llr[0]
  lon=llr[1]
  r=llr[2]
  aeroid_r=marsaeroid(aclat,lon)
  topo_h=marstopo_lo(aclat,lon)
  topo_r=topo_h+aeroid_r
  alt=r-aeroid_r; Altitude relative to aeroid, used for atmosphere
  agl=r-topo_r; Altitude relative to topography, used for radar altimeter and collision detection
  if agl lt 0 then message,'Ground impact'  

  marsatm,aclat,lon,alt,t=tempK,p=p,rho=rho,csound=csound
  
  ;Velocity of vehicle relative to air, in inertial frame
  vwind_i=transpose(mrmme2iau) ## v_rel
  
  ;Mass properties of the vehicle
  phoenix_mass_prop,m=m,I=I,CoM=CoM
    
  ;Calculate gravity in the relative frame and transform it back to the inertial frame
  ag_rel=marsgrav(r_rel)
  ag_i=transpose(mrmme2iau) ## ag_rel
  ;Accumulate the acceleration
  a_i+=ag_i
  
  ;calculate force and moment from airfoil
  phoenix_airfoil,vwind_i,ei2b,rho,csound,f=f,torque=torque,coa=coa
  
  ;calculate torques
  ;Translation kinematics
  rd_i=v_i
  vd_i=a_i
  
  ;Rotation kinematics
  ei2bd=transpose(quat_mult_grid(ei2b,[[w_b],[0]])/2)
  wd_b=invert(I) ## (N_b-transpose(crossp_grid(w_b,I ## w_b)))
    
  ;Form it all up into a column vector and return
  return,[[rd_i],[vd_i],[ei2bd],[wd_b]]
end
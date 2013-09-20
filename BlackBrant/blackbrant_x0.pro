function blackbrant_x0,el=launch_el,az=launch_az,spd=rail_exit_spd,alt=rail_alt,lat=launch_lat,lon=launch_lon,t0=t0
  ;state at rail exit
  r0=xyz_to_lla(/inv,[launch_lat,launch_lon,rail_alt])
  m0=1700.15+max([t0,0])*(-110.56021d) ;mass of fuel only, at rail exit (or fully loaded if t0 lt 0)
  
  ;local topocentric system - Z points at zenith, E points at East in horizon, N points at North in horizon
  z=normalize_grid(r0)
  e=normalize_grid(crossp_grid([0d,0,1],z))
  n=normalize_grid(crossp_grid(z,e))
  
  p_r=transpose(z*sin(launch_el)+e*sin(launch_az)*cos(launch_el)+n*cos(launch_az)*cos(launch_el))
  t_r=transpose(e)
  
  ;body axis - Z is towards nose, X and Y are perpendicular. X is arbitrarily "left wing" and Y is arbitrarily "tail"
  p_b=transpose([0d,0,1])
  t_b=transpose([0d,1,0])
  ;point_toward returns a b2r matrix, we want an r2b quaternion
  q0=quat_to_mtx(/inv,transpose(point_toward(p_r=p_r,p_b=p_b,t_r=t_r,t_b=t_b)))
    
  v0=p_r*rail_exit_spd+vwind(r0)
  w0=[0d,0,0]  ;body rotation rates, rad/s
  x0=transpose([r0,v0[*],[0,0,0],q0[*],w0,m0])
  xd=call_function('fd_blackbrant',t0,x0)
  x0[6:8]=xd[3:5] ;stick acceleration into state vector

  return,x0
end
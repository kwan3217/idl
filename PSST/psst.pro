;Program to Simulate Simulated Trajectories. Modeled on the legendary POST2,
;Program to Optimize Simulated Trajectories used by NASA.
;
;Units: SI as near as possible. Angles in radians, distances in meters, 
;       time in seconds, mass in kg, amount of substance in kmol (an exception, 
;       so that molecular mass in kg/kmol is the customary molecular weight number)
;       all derived units are SI primary derived units (N, Pa, etc)
;Atmosphere model: A program which takes 
;       lat,lon - Planetocentric latitude and longitude in radians
;       alt     - Altitude above equipotential in m
;  and has output parameters
;       T=      - Temperature at this altitude in K
;       P=      - Pressure at this altitude in Pa
;       rho=    - Density at this altitude in kg/m^3 (water=1000)
;       csount= - velocity of sound in m/s
;Equipotential model: A function which takes
;       lat,lon - Planetocentric latitude and longitude in radians
;  and returns
;       distance from planet center to reference equipotential surface (geoid, aeroid, etc)
;Topography model: Same as Equipotential model
pro PSST
  ;Calculate initial condition in MME frame
  et0=265030323.10503286d
  fps=200d
  dlm_register,'C:\Users\jeppesen\Documents\LocalApps\spice\icy64_7\lib\icy.dlm'
  cd,'../../Data/spice/Phoenix',current=current
  cspice_furnsh,'Phoenix.tm'
  cd,current
  target='PHX'
  n=90000
  et1=et0+double(n)/fps
  et=et0+dindgen(n)/fps  

  cspice_spkezr,target,et0,'PHX_MME_2000','NONE','MARS',state_i,ltime
  cspice_sce2c,-84,et0,sclkdp
;C     REF        is the desired reference frame for the returned
;C                pointing and angular velocity.  The returned C-matrix
;C                CMAT gives the orientation of the instrument
;C                designated by INST relative to the frame designated by
;C                REF.  When a vector specified relative to frame REF is
;C                left-multiplied by CMAT, the vector is rotated to the
;C                frame associated with INST. The returned angular
;C                velocity vector AV expresses the angular velocity of
;C                the instrument designated by INST relative to the
;C                frame designated by REF.  See the discussion of CMAT
;C                and AV below for details.
;C
;C     CMAT       is a rotation matrix that transforms the components of
;C                a vector expressed in the reference frame specified by
;C                REF to components expressed in the frame tied to the
;C                instrument, spacecraft, or other structure at time
;C                CLKOUT (see below).
;C
;C                Thus, if a vector v has components x,y,z in the REF
;C                reference frame, then v has components x',y',z' in the
;C                instrument fixed frame at time CLKOUT:
;C
;C                     [ x' ]     [          ] [ x ]
;C                     | y' |  =  |   CMAT   | | y |
;C                     [ z' ]     [          ] [ z ]
;C
;C                If you know x', y', z', use the transpose of the
;C                C-matrix to determine x, y, z as follows:
;C
;C                     [ x ]      [          ]T    [ x' ]
;C                     | y |  =   |   CMAT   |     | y' |
;C                     [ z ]      [          ]     [ z' ]
;C                              (Transpose of CMAT)
;C
;C     AV         is the angular velocity vector. This is the axis about
;C                which the reference frame tied to the instrument is
;C                rotating in the right-handed sense at time CLKOUT. The
;C                magnitude of AV is the magnitude of the instantaneous
;C                velocity of the rotation, in radians per second.  AV
;C                is expressed relative to the frame designated by REF.

;In our case, REF is the inertial frame and the instrument frame is the body frame,
;so we use call cmat, m_i2b and use it to transform av_i from ref to body av_b, then
;make a quaternion e_i2b out of m_i2b 
  cspice_ckgpav,-84000,sclkdp,0,'PHX_MME_2000',m_i2b,av_i,clkout,found
  
  if(~found) then message,'No pointing found for the given time'
  
  ;In keeping with standard left-multiplication matrix notation, all vectors are to be column vectors.
  ;Also, convert position/velocity to m and s.
  state_i=[[transpose(state_i*1000d)],[quat_to_mtx(m_i2b,/inv)],[m_i2b ## transpose(av_i)]]
  state_hist=dblarr(n,n_elements(state_i))
  ;euler integration
  for i=0,n-1 do begin
    state_i+=psst_derivative(state_i,et0+double(i)/fps)/fps;
    ;Constrain the quaternion to unit length
    state_i[6:9]=state_i[6:9]/sqrt(total(state_i[6:9]^2))
    state_hist[i,*]=state_i
  end
  
  fps2=24.0d
  n_fps=(et1-et0)*fps2
  et_fps=et0+dindgen(n_fps)/fps2
  state_downsample=dblarr(n_fps,n_elements(state_i))
  for i=0,n_elements(state_i)-1 do state_downsample[*,i]=interpol(state_hist[*,i],et,et_fps)
  
  edl_oufn='psst.inc'
    openw,/get_lun,ouf,edl_oufn
  printf,ouf,'//All distances in meters, all time in seconds, all angles in radians, all derived units in SI primary derived units
  printf,ouf,'//i - Zero-based frame number'
  printf,ouf,'//et - SCET(ET) of this frame, in seconds since J2000 ET epoch'
  printf,ouf,'//deltaet - time from frame zero, in seconds'
  printf,ouf,'//r=<rx,ry,rz> - Vector from center of Mars to spacecraft in MME frame in meters'
  printf,ouf,'//v=<vx,vy,vz> - Relative velocity vector of spacecraft in MME frame in m/s. Airspeed, discounting local wind'
  printf,ouf,'//e=<ex,ey,ez,ew> - Quaternion which converts an inertial vector to a body vector when used as r_b=e''*r_i*e'
  printf,ouf,format='(%"array[%5d][15] {")',n_fps
  printf,ouf,'//          0                     1                      2                  3                  4                  5                  6                  7                  8                  9                 10                 11                 12                 13                 14'
  printf,ouf,'//     i,  et,                   deltaet,               rx,                ry,                rz,                vx,                vy,                vz,                ex,                ey,                ez,                ew,                wx,                wy,                wz'
  for i=0,n_fps-1 do begin ;-2 since we have one less drag measurement than state vector
    printf,ouf,format='(%"/*%6d*/{%21.14e,%21.14e,' + $ i,et,deltaet
                      '%18.10e,%18.10e,%18.10e,' + $ rx,ry,rz
                      '%18.10e,%18.10e,%18.10e,' + $ vx,vy,vz
                      '%18.10e,%18.10e,%18.10e,%18.10e,' + $ ex,ey,ez,ew
                      '%18.10e,%18.10e,%18.10e},")', $ wx,wy,wz
                      i,et0+double(i)/fps2,double(i)/fps2, $
                      state_downsample[i, 0],state_downsample[i, 1],state_downsample[i, 2], $
                      state_downsample[i, 3],state_downsample[i, 4],state_downsample[i, 5], $
                      state_downsample[i, 6],state_downsample[i, 7],state_downsample[i, 8],state_downsample[i, 9], $
                      state_downsample[i,10],state_downsample[i,11],state_downsample[i,12]
  end
  printf,ouf,'}'
  
  free_lun,ouf

  tau=2*!dpi ;tau manifesto
  wind=crossp_grid([0,0,350.89198226/86400d/360d*tau],state_hist[*,0:2])
  
  vrel=state_hist[*,3:5]-wind

  x_b=transpose([1,0,0])
  x_i=transformgrid(quat_invert(state_hist[*,6:9]),x_b)
  plot,vangle(vrel,x_i)*!radeg
  print,'done'
end
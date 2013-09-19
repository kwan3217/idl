;%Calculate the observation, using the reentry equations of motion
;%  t - timestamp in s, not used with these particular equations
;%  x - state vector, in km and s for length and time units
;%        x[0] is Earth-centered x coordinate, km
;%        x[1] is Earth-centered y coordinate, km
;%        x[2] inertial velocity in x direction, km/s
;%        x[3] inertial velocity in y direction, km/s
;%        x[4] is scaling factor of ballistic coefficient, beta=beta0*exp(x[4]).
;%             Done this way so that any real value of x[4], positive, negative,
;%             or otherwise, gives a positive ballistic coefficient
;%  w - measurement noise vector. Optional, defaults to a zero vector the size of the 
;%      measurement vector. This is the actual specific value of the measurement noise
;%      at this time t, the value usually considered "unknown" to the filter. For these
;%      equations, 
;%        w[0] is noise on range in km
;%        w[1] is noise on azimuth in radians
;%return
;%  z - Observation (column, [1,2]) vector
;%        z[0] is range in km
;%        z[1] is azimuth in radians
;%This process is used for the "reentry problem" commonly used to test filters
;%because of its strong nonlinearity. This represents the observation of a spacecraft
;%by a radar station on the surface of the Earth, with range and azimuth measurements. 
;%See UKF0.pdf, section 4.
function g_reentry,t,x,w
  if n_elements(w) eq 0 then w=[0,0];
  xr=6374;
  yr=0;
  rho=sqrt((x[0]-xr)^2+(x[1]-yr)^2)+w[0];
  theta=atan((x[1]-yr),(x[0]-xr))+w[1];
  return,transpose([rho,theta]);

end

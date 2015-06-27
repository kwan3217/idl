;%Calculate the Jacobian of the observation, using the reentry equations of motion
;%  t - timestamp in s, not used with these particular equations
;%  x - state vector, in km and s for length and time units
;%        x[0] is Earth-centered x coordinate, km
;%        x[1] is Earth-centered y coordinate, km
;%        x[2] inertial velocity in x direction, km/s
;%        x[3] inertial velocity in y direction, km/s
;%        x[4] is scaling factor of ballistic coefficient, beta=beta0*exp(x[4]).
;%             Done this way so that any real value of x[4], positive, negative,
;%             or otherwise, gives a positive ballistic coefficient
;%return
;%  HH - Jacobian of observation
;%This process is used for the "reentry problem" commonly used to test filters
;%because of its strong nonlinearity. This represents the observation of a spacecraft
;%by a radar station on the surface of the Earth, with range and azimuth measurements. 
;%See UKF0.pdf, section 4.
function dgdx_reentry,t,x
  xs=6374;
  ys=0;
  rx=x[0];
  ry=x[1];
  HH=[[(rx-xs)/sqrt((ry-ys)^2+(rx-xs)^2),(ry-ys)/sqrt((ry-ys)^2+(rx-xs)^2),0,0,0],$
      [-(ry-ys)/((rx-xs)^2*((ry-ys)^2/(rx-xs)^2+1)),1/((rx-xs)*((ry-ys)^2/(rx-xs)^2+1)),0,0,0]]
  return,HH
end

;%Calculate the derivative of the state, using the reentry equations of motion
;%  t - timestamp in s, not used with these particular equations
;%  x - state vector, in km and s for length and time units
;%        x[0] is Earth-centered x coordinate, km
;%        x[1] is Earth-centered y coordinate, km
;%        x[2] inertial velocity in x direction, km/s
;%        x[3] inertial velocity in y direction, km/s
;%        x[4] is scaling factor of ballistic coefficient, beta=beta0*exp(x[4]).
;%             Done this way so that any real value of x[4], positive, negative,
;%             or otherwise, gives a positive ballistic coefficient
;%  v - process noise vector. If unknown, pass a zero vector the size of the state
;%      vector. This is the actual specific value of the process noise at this 
;%      time t, the value usually considered "unknown" to the filter. For these
;%      equations, 
;%        v[0] is unused, would be noise on x velocity in m/s 
;%        v[1] is unused, would be noise on y velocity in m/s
;%        v[2] is noise on x acceleration in m/s^2
;%        v[3] is noise on y acceleration in m/s^2
;%        v[4] is noise on ballistic coefficient rate
;%return
;%  xd - Derivative of state, in the form of a column vector [1,5] 
;%This process is used for the "reentry problem" commonly used to test filters
;%because of its strong nonlinearity. This represents the equations of motion 
;%of a spacecraft with drag above the Earth. See UKF0.pdf, section 4.
function fd_reentry,t,x,v
  ;%model constants
  beta0=0.59783;  
  Gm0=398600;  %Gravitational constant of Earth km and s
  R0=6374;     %Surface radius, km
  H0=13.406;   %Atmosphere scale height, km

  RR=sqrt(x[0]^2+x[1]^2);
  VV=sqrt(x[2]^2+x[3]^2);
  beta=beta0*exp(x[4]);
  GG=-Gm0/RR^3;
  DD=-beta*exp((R0-RR)/H0)*VV;
  xd=dblarr(1,5)
  xd[0]=x[2];
  xd[1]=x[3];
  xd[2]=DD*x[2]+GG*x[0]+v[2];
  xd[3]=DD*x[3]+GG*x[1]+v[3];
  xd[4]=0              +v[4];
  return,xd;
end

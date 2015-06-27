;%Calculate the Jacobian of the state, using the reentry equations of motion
;%  t - timestamp in s, not used with these particular equations
;%  x - state vector, in km and s for length and time units
;%        x(1) is Earth-centered x coordinate, km
;%        x(2) is Earth-centered y coordinate, km
;%        x(3) inertial velocity in x direction, km/s
;%        x(4) inertial velocity in y direction, km/s
;%        x(5) is scaling factor of ballistic coefficient, beta=beta0*exp(x(5)).
;%             Done this way so that any real value of x(5), positive, negative,
;%             or otherwise, gives a positive ballistic coefficient
;%return
;%  Phi - Derivative of state 
;%This process is used for the "reentry problem" commonly used to test filters
;%because of its strong nonlinearity. This represents the equations of motion 
;%of a spacecraft with drag above the Earth. See UKF0.pdf, section 4.
function dfdx_reentry,t,x
  rx=x[0];
  ry=x[1];
  vx=x[2];
  vy=x[3];
  reldens=x[4];
  Gm0=398600;
  R0=6374;
  beta0=0.59783;
  H0=13.406;
  Phi=[[0,0,1,0,0],$
       [0,0,0,1,0],$
       [beta0*rx*vx*sqrt(vy^2+vx^2)*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)/(sqrt(ry^2+rx^2)*H0)-Gm0*(ry^2+rx^2)^((-3.0)/2.0)+3*Gm0*rx^2*(ry^2+rx^2)^((-5.0)/2.0),beta0*ry*vx*sqrt(vy^2+vx^2)*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)/(sqrt(ry^2+rx^2)*H0)+3*Gm0*rx*ry*(ry^2+rx^2)^((-5.0)/2.0),-beta0*sqrt(vy^2+vx^2)*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)-beta0*vx^2*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)/sqrt(vy^2+vx^2),-beta0*vx*vy*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)/sqrt(vy^2+vx^2),-beta0*vx*sqrt(vy^2+vx^2)*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)],$
       [beta0*rx*vy*sqrt(vy^2+vx^2)*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)/(sqrt(ry^2+rx^2)*H0)+3*Gm0*rx*ry*(ry^2+rx^2)^((-5.0)/2.0),beta0*ry*vy*sqrt(vy^2+vx^2)*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)/(sqrt(ry^2+rx^2)*H0)-Gm0*(ry^2+rx^2)^((-3.0)/2.0)+3*Gm0*ry^2*(ry^2+rx^2)^((-5.0)/2.0),-beta0*vx*vy*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)/sqrt(vy^2+vx^2),-beta0*sqrt(vy^2+vx^2)*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)-beta0*vy^2*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)/sqrt(vy^2+vx^2),-beta0*vy*sqrt(vy^2+vx^2)*exp((R0-sqrt(ry^2+rx^2))/H0+reldens)],$
       [0,0,0,0,0]];
  return,Phi
end

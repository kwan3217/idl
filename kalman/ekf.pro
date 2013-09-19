;%General-purpose implementation of the Extend Kalman filter for a continuous 
;%  process measured at discrete times.
;%Four function reference arguments to describe the problem
;%  fd -   Physics function dx/dt=fdot(x,t). Figures the derivative of the state 
;%           given the current state and time
;%  dfdx - Physics Jacobian Function dF/dx=dfdt(x,t). Returns a matrix where each
;%           element (i,j) is the derivative of component i of the physics 
;%           function with respect to component j of the state vector at time t
;%  g  - Observation function g=g(x,t). Figures the observation vector from the
;%           state given the current time
;%  dgdx - Observation Jacobian dg/dx=dgdx(x,t). Returns a matrix where each
;%           element (i,j) is the derivative of component i of the observation
;%           with respect to component j of the state
;%Three arguments describing the current state
;%  t0 - A priori time stamp (presumed completely accurate)
;%  x - A priori State vector estimate, valid at t0
;%  PP - A priori state vector estimate covariance, valid at t0
;%Five arguments describing the propagation and observation
;%  t1 - A posteriori time stamp
;%  nstep - Number of integration steps to take between t0 and t1
;%  z - Observation vector, valid at t1
;%  QQ - Process noise covariance between t0 and t1
;%  RR - Observation noise covariance at t1
;%Return arguments
;%  x - A posteriori state vector estimate, valid at t1
;%  PP - A posteriori state vector estimate covariance, valid at t1
;%  ZZ - Measurement innovation
;%  KK - Kalman gain matrix
;%  xm - A priori updated state vector estimate. Propagated to t1, but no measurement 
;%          update (x above includes both propagation and measurement update)
;%  Pmm - A priori updated state vector estimate covariance. Same condition as xm above
;%  AA - State transition matrix - linearized as described in the algorithm
;%  HH - Observation matrix - linearized as above
;%  XX - State deviation vector
function ekf,fd,g,t0,x,PPkm1,t1,nstep,z,QQ,RR,dfdx=dfdx,dgdx=dgdx,PP=PP,ZZ=ZZ,KK=KK,xm=xm,Pmm=PPm,AA=AA,HH=HH,XX=XX
  deltat=t1-t0;
  if deltat gt 0 then begin
    xm=fekf(fd,dfdx,t0,x,t1,nstep,AA=AA);
    PPm=AA##PPkm1##transpose(AA)+QQ;
  end else begin
    xm=x;
    PPm=PPkm1;
  end
  HH=call_function(dgdx,t1,xm);
  KK=PPm##transpose(HH)##kf_inv(HH##PPm##transpose(HH)+RR);
  ZZ=z-call_function(g,t1,xm);
  XX=KK##ZZ;
  x=xm+XX;
  PP=PPm-KK##HH##PPm;
  return,x
end

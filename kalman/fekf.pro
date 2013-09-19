;%Augmented process propagator for a continuous process from a given time to another time
;%Two function reference arguments to describe the process
;%  fd -   Physics function dx/dt=fdot(x,t). Figures the derivative of the state 
;%           given the current state and time
;%  dfdx - Physics Jacobian Function dF/dx=dfdt(x,t). Returns a matrix where each
;%           element (i,j) is the derivative of component i of the physics 
;%           function with respect to component j of the state vector at time t
;%Three arguments describing the current state
;%  t0 - A priori time stamp (presumed completely accurate)
;%  xkm - A priori State vector estimate, valid at t0
;%Two arguments describing the propagation and observation
;%  t1 - A posteriori time stamp
;%  nstep - Number of integration steps to take between t0 and t1
;%One argument describing the process noise (optional)
;%  v - process noise vector, the thing usually considered "unknown" by the filter
;%      If not passed, zero vector the size of the state is used
;%Return arguments
;%  xk - A posteriori state vector estimate, valid at t1
;%  AA - State transition matrix - linearized as described in the algorithm
function fekf,fd,dfdx,t0,xkm,t1,nstep,v,AA=AA
  if n_elements(v) eq 0 then v=dblarr(size(xkm,/dim));
  deltat=t1-t0;
  n=n_elements(xkm);
  xkam=[reform(xkm),reform(identity(n),n*n)]

  t=t0;
  for i=0,nstep-1 do begin	
    xkam=xkam+(deltat/nstep)*fekfd(fd,dfdx,t,xkam,v);
    t=t0+(deltat*i)/nstep;
  end
  xka=xkam;

  xk=transpose(xka[0:n-1]);
  AA=reform(xka[n:*],n,n);
  return,xk
end
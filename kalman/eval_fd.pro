;Process propagator for a continuous process from a given time to another time
;One function name argument to describe the process
;  fd -   Physics function dx/dt=fdot(x,t). Figures the derivative of the state 
;           given the current state and time
;Two arguments describing the current state
;  t0 - A priori time stamp (presumed completely accurate)
;  xkm - A priori State vector, valid at t0
;Two arguments describing the propagation and observation
;  t1 - A posteriori time stamp
;  nstep - Number of integration steps to take between t0 and t1
;One argument describing the process noise (optional)
;  v - process noise vector, the thing usually considered "unknown" by the filter
;      If not passed, zero vector the size of the state is used
;Return arguments
;  xk - A posteriori state vector, valid at t1. IFF t1 eq t0, then xkm will be returned
;       unmodified, even by process noise.
function eval_fd,fd,t0,xkm,t1,nstep,v
  deltat=t1-t0;
  if deltat eq 0 then return,xkm

  if n_elements(v) eq 0 then v=dblarr(size(xkm,/dim));
  t=t0;
  xk=xkm;
  for i=0,nstep-1 do begin	
    xk=xk+(deltat/nstep)*call_function(fd,t,xk,v);
    t=t0+(deltat*i)/nstep;
  end
  return,xk
end


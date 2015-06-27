;%Derivative function for fekf()
;%Two function reference arguments to describe the process
;%  fd -   Physics function dx/dt=fdot(x,t). Figures the derivative of the state 
;%           given the current state and time
;%  dfdx - Physics Jacobian Function dF/dx=dfdt(x,t). Returns a matrix where each
;%           element (i,j) is the derivative of component i of the physics 
;%           function with respect to component j of the state vector at time t
;%Two arguments describing the current state
;%  t - time stamp (presumed completely accurate)
;%  xa - State vector, augmented with state transition matrix, valid at t
;%One argument describing the process noise
;%  v - process noise vector, the thing usually considered "unknown" by the filter
;%Return arguments
;%  xad - Derivative of augmented state vector
function fekfd,fd,dfdx,t,xa,v

  NN=n_elements(xa);
  ;%We know that the augmented state vector is N=n+n^2 elements
  ;%So, we run it through the quadratic formula a=1,b=1,c=-N, n=(-1+sqrt(1+4*N))/2
  n=(sqrt(1+4*NN)-1)/2;

  ;%Split off state transition matrix
  x=transpose(xa[0:n-1]);
  AA=reform(xa[n:*],n,n);
  ;%Calculate normal fd part
  xd=call_function(fd,t,x,v);

  ;%Calculate physics matrix
  Phi=call_function(dfdx,t,x);

  ;%Calculate derivative of state transition matrix
  AAd=Phi##AA;

  ;%Recombine augmented state vector derivative
  xad=[reform(xd),reform(AAd,n*n)];
  return,xad
end

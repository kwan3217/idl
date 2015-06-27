;Unscented Kalman filter with additive noise, therefore unaugmented
;General-purpose implementation of the Unscented Kalman filter for a continuous 
;  process measured at discrete times. The filter has additive noise, and
;  is therefore unaugmented. See TutorialUKF.pdf on the wiki
;Two function reference arguments to describe the problem
;  fd -   Physics function dx/dt=fdot(x,t). Figures the derivative of the state 
;           given the current state and time
;  g  - Observation function g=g(x,t). Figures the observation vector from the
;           state given the current time
;Three arguments describing the current state
;  t0 - A priori time stamp (presumed completely accurate)
;  xkm1 - A priori State vector estimate, valid at t0
;  PPkm1 - A priori state vector estimate covariance, valid at t0
;Five arguments describing the propagation and observation
;  t1 - A posteriori time stamp
;  nstep - Number of integration steps to take between t0 and t1
;  z - Observation vector, valid at t1
;  QQ - Process noise covariance between t0 and t1
;  RR - Observation noise covariance at t1
;Return arguments
;  xk - A posteriori state vector estimate, valid at t1
;  PP= - A posteriori state vector estimate covariance, valid at t1
;  ZZ= - Measurement innovation
;  KK= - Kalman gain
function lukf,fd,g,t0,xkm1,PPkm1,t1,nstep,z,QQ,RR,PP=PP,ZZ=ZZ,KK=KK
  n=n_elements(xkm1);
  m=n_elements(z);
  
  ;Create the sigma points
  WW0=1d/3d; %Suggested for Gaussian noises
  WWj=(1-WW0)/(2*n); 
  WW=[WW0,(dblarr(2*n,1)+1)*WWj] ;  %Weighting of sigma points
  xjkm1=dblarr(1,n,n*2+1)        ; %Matrix of sigma points [1,state,n_sigma_points]
  xjkm1[0,*,0]=xkm1              ; %Each column is a single sigma point
                                 ; %First sigma point is the original state
  rPPkm1=PPkm1                           
  la_choldc,rPPkm1; %Matrix square root (lower triangluar, P=A*A')
  for i=1,n-1 do rPPkm1[i,0:i-1]=0 ;erase the upper triangular
  rPPkm1=sqrt(n/(1-WW0))*rPPkm1; %scale to do sigma points
  ;UKF1, p6 (406), footnote 5: 
  ;"If the matrix square root [A] of [P] is of the form [P]=[A^T][A], then
  ;the sigma points are formed from the ''rows'' of [A]. However, if the
  ;matrix square root is of the form [P]=[A][A^T], the ''columns'' are
  ;used. "
  ;Matlab produces an upper triangular P=A'*A, so it matches the first form.
  ;IDL can do either, and we want to use the lower form so we can use cholupdate
  ;so we need to use columns. This will result in a vector with n nonzero
  ;components for the first dimension and 1 nonzero component for the last.
  ;Doing this wrong results in 1 nonzero component for the first dimension
  ;and n for the last.
  for i=0,n-1 do begin
    ;Positive sigma point
    xjkm1[0,*,i+1  ]=xkm1+rPPkm1[i,*];   % (7) taking columns of rPPkm1
    ;Negative sigma point
    xjkm1[0,*,i+1+n]=xkm1-rPPkm1[i,*];   % (8) taking columns of rPPkm1
  end;

  ;Model forecast
  xfjk=dblarr(size(xjkm1,/dim)); %Keep track of each transformed sigma point
  xfk= dblarr(1,n);              %accumulate forecast estimate
  for j=0,2*n do begin
    xfjk[0,*,j]=eval_fd(fd,t0,xjkm1[0,*,j],t1,nstep);  % (11)
    xfk=xfk+WW[j]*xfjk[0,*,j];                         % (12)
  end
  PPfk=QQ;                %Accumuate forecast covariance, start with additive process noise
  for j=0,2*n do begin
    PPfk=PPfk+WW[j]*(xfjk[0,*,j]-xfk)##transpose(xfjk[0,*,j]-xfk); % (13)
  end

  ;Measurement forecast (TutorialUKF.pdf is wrong, should put forecast, not original
  ;                      estimate, through observation transform. UKF0.pdf 
  ;                      shows the algorithm as actually done below.)
  zfjk=dblarr(1,m,1+2*n);     %Keep track of each transformed sigma point
  zfk=dblarr(1,m);          %accumulate forecast measurement
  for j=0,2*n do begin
    zfjk[0,*,j]=call_function(g,t1,xfjk[0,*,j]);       % (14)
    zfk=zfk+WW[j]*zfjk[0,*,j];                         % (15)
  end
  Gamma=RR;          %Accumulate innovation covariance (paper Cov(z~fkm1)), start with additive measurement noise
  SS=dblarr(m,n);    %Accumulate cross covariance      (paper Cov(x~fk,z~fkm1))
  for j=0,2*n do begin
    Gamma=Gamma+WW[j]*(zfjk[0,*,j]-zfk)##transpose(zfjk[0,*,j]-zfk); % (16)
    SS=SS+WW[j]*(xfjk[0,*,j]-xfk)##transpose(zfjk[0,*,j]-zfk);       % (17)
  end
  
  ;Data Assimilation
  KK=SS ## kf_inv(Gamma);
  ;KKk=SSk/Gammak;                     % (19)
  ZZ=z-zfk; %Innovation, calculated separately so can be returned
  xk=xfk+KK##ZZ;                       % (18)
  PP=PPfk-KK##Gamma##transpose(KK);   % (20) This is not the (1-KH)P that the linear filter uses
                                   ;          because H is not directly available. The linear filter
                                   ;          can be manipulated to this form, see the wiki for details
  return,xk
end
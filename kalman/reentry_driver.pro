pro reentry_driver

tic

;% Example driver:
seed=3217;

;%Set up the various filters
;%EKF needs a couple of extra parameters, the Jacobian functions, so set it up as an anonymous 
;%function with those passed already
;kf_e=@(fd,g,t0,x,PP,t1,nstep,z,QQ,RR) ekf(fd,g,@dfdx_reentry,@dgdx_reentry,t0,x,PP,t1,nstep,z,QQ,RR);
extra={dfdx:'dfdx_reentry',dgdx:'dgdx_reentry'}
;%Various flavors of unscented Kalman filter
kf=['lukf','ekf']; %Array of Kalman Filters to try
nk=n_elements(kf);   %Number of filters
fd='fd_reentry'; %Physics Function
g='g_reentry';   %Observation function

;%timing
tf=200;         %Total time of flight, s. Cut this off before it hits the ground, please! Ground is unmodeled
deltat=0.1;       %Time between measurements, s
deltatstep=0.05;%Time between propagation steps, s
nstep=deltat/deltatstep;
NN=tf/deltat;               % total dynamic steps

n=5;      %number of state
m=2;      %number of obs
s=transpose([6500.4,349.14,-1.8093,-6.7967,0]);  % initial true state
x=s;                                  
x[4]=0.6392;                                    % initial state estimate
p=[1e-6,1e-6,1e-6,1e-6,1];
PP = dblarr(n,n)
for i=0,n-1 do PP[i,i]=p[i];                              % initial state covraiance

;%Time histories of various things. In all cases except time stamp, these are grids of vectors or matrices. 
;All vectors in this algorithm are column vectors, which are represented in IDL as [1,x] arrays. The grid 
;indices are always time step third and filter implemnetation (if needed) fourth
tV  = dblarr(NN+1);         %Time stamps [time steps]
sV  = dblarr(1,n,NN+1);     %actual state vector [1,state vector component, step]
zV  = dblarr(1,m,NN+1);     %actual measurement  [1,measurement component, step]
xV  = dblarr(1,n,NN+1,nk);  %estmate for each filter [1, state, step, filter]
ZZV = dblarr(1,m,NN+1,nk);  %Measurement deviation for each filter [1, meas, step, filter]
PPV = dblarr(n,n,NN+1,nk);  %Estimate covariance for each filter   [state column, state row, step, filter]
KKV = dblarr(m,n,NN+1,nk);  %Kalman gain for each filter           [meas column,  state row, step, filter]

q=transpose([0,0,2.4064e-5,2.4064e-5,0]); %Process noise diagonal
QQ=dblarr(n,n)
for i=0,n-1 do QQ[i,i]=q[i]
QQ[4,4]=1e-6;
r=transpose([0.1^2,1.7e-3^2]);
RR=dblarr(m,m);
for i=0,m-1 do RR[i,i]=r[i]
k=0;

;%Store initial history
tV[0]=0;
sV[0,*,0]= s;       % true state
zV[0,*,0]= call_function(g,tV[0],s);  % measurement
for i=0,nk-1 do begin
  xV [0,*,0,i]=x;      % estimate
  ZZV[0,*,0,i]=zV[0,*,0];
  PPV[*,*,0,i]=PP;
end

;%Generate all the process noise and measurement noise up front
vV=randomn(seed,1,n,NN+1)*rebin(sqrt(q),1,n,NN+1);
wV=randomn(seed,1,m,NN+1)*rebin(sqrt(r),1,m,NN+1);

for k=1,NN do begin
  t1=deltat*k;
  t0=deltat*(k-1);
  v=vV[0,*,k];
  s=eval_fd(fd,t0,s,t1,nstep,v);
  
  w=wV[0,*,k];
  z = call_function(g,t1,s,w);

  tV[k]=t1;       % save time stamp
  sV[0,*,k]= s;       % save actual state
  zV[0,*,k]= z;       % save measurement

  for i=0,nk-1 do begin
    inx=xV[0,*,k-1,i];
    inPP=PPV[*,*,k-1,i];
    this_kf=kf[i];
    outx=call_function(this_kf,fd,g,t0,inx,inPP,t1,nstep,z,QQ,RR,PP=outPP,ZZ=outZZ,KK=outKK,_extra=extra);

    xV [0,*,k,i]=outx;     % save estimate
    PPV[*,*,k,i]=outPP;    % save covariance
    ZZV[0,*,k,i]=outZZ;    % save measurement
    KKV[*,*,k,i]=outKK;    % save Kalman gain
  end

end

device,dec=1
color=['ff0000'x,'00ff00'x,'0000ff'x,'ffff00'x,'ff00ff'x,'00ffff'x,'ffffff'x];
swindow,0
!p.multi=0
plot,sV[0,0,*],sV[0,1,*],psym=0,color='ffffff'x,/iso
oplot,[6374,6374],[0,0],psym=4,color='ffffff'x
oplot,sqrt(6374.0^2-(dindgen(600)-100)^2),dindgen(600)-100,psym=0,color=color[0]
oplot,sqrt(6474.0^2-(dindgen(600)-100)^2),dindgen(600)-100,psym=0,color=color[1]
for i=0,nk-1 do begin
  oplot,xV[0,0,*,i],xV[0,1,*,i],psym=0,color=color[i]
end

swindow,1

titles=['x','y','xd','yd','cd'];
units=['km','km','km/s','km/s','ln(beta)'];

!p.multi=[0,3,2]
for i=0,4 do begin
  plot,tV,abs(sV[0,i,*]-xV[0,i,*,0]),title=titles[i],xtitle='time (s)',ytitle=titles[i]+' ('+units[i]+')',charsize=3
  for j=0,nk-1 do begin
    oplot,tV,abs(sV[0,i,*]-xV[0,i,*,j]),color=color[j]
    oplot,tV,sqrt(PPV[i,i,*,j]),color=color[j],linestyle=1
  end
end

toc

end
pro blackbrant_filter

tic

;% Example driver:
seed=3217;

;%Set up the various filters
kf='lukf'; %Kalman Filters to use
fd='fd_rocketometer'; %Physics Function
g='g_rocketometer';   %Observation function

restore,'BlackBrantClean.sav'
toc,'restored simulation'
nstep=1;
NN=(size(z,/dim))[0]-1;               % total dynamic steps

s=x[0,*]
n=n_elements(s);      %number of state elements
m=n_elements(call_function(g,t0,s));                  %number of obs elements
p=[1d,1,1,0.1d,0.1d,0.1d,0.1d,0.1d,0.1d,1d-3,1d-3,1d-3,1d-3,1d-3,1d-3,1d-3,1d];
PP = dblarr(n,n)
for i=0,n-1 do PP[i,i]=p[i];                              % initial state covraiance

;%Time histories of various things. In all cases except time stamp, these are grids of vectors or matrices. 
;All vectors in this algorithm are column vectors, which are represented in IDL as [1,x] arrays. The grid 
;indices are always time step third and filter implemnetation (if needed) fourth
tV  = temporary(t);         %Time stamps [time steps]
sV  = reform(transpose(temporary(x)),1,n,NN+1);     %actual state vector [1,state vector component, step]
zV  = reform(transpose(temporary(z)),1,m,NN+1);     %actual measurement  [1,measurement component, step]
xV  = dblarr(1,n,NN+1);  %estmate for each filter [1, state, step]
ZZV = dblarr(1,m,NN+1);  %Measurement deviation for each filter [1, meas, step]
PPV = dblarr(n,n,NN+1);  %Estimate covariance for each filter   [state column, state row, step]
KKV = dblarr(m,n,NN+1);  %Kalman gain for each filter           [meas column,  state row, step]

;%Process noise diagonal
q=transpose([0d,0,0, $ ;no process noise on position
             0d,0,0, $ ;no process noise on velocity
             10d,10,10, $;Lots of process noise on acceleration
             0d,0,0,0, $;no process noise on quaternion
             10d,10,10, $;Lots of process noise on rotation rate
             0d])        ;no process noise on mass 
QQ=dblarr(n,n)
for i=0,n-1 do QQ[i,i]=q[i]
r=transpose([100d,100,100,100,100,100,100,100,100]);measurement noise, 10DN on each axis, uncorrelated
RR=dblarr(m,m);
for i=0,m-1 do RR[i,i]=r[i]

;%Store initial history
xV [0,*,0]=sV[0,*,0];      % estimate
ZZV[0,*,0]=zV[0,*,0];
PPV[*,*,0]=PP;

for k=1,NN do begin
  t1=tV[k];
  t0=tV[k-1];
  
;  w=wV[0,*,k];
  z = zV[0,*,k];

  inx=xV[0,*,k-1];
  inPP=PPV[*,*,k-1];
  outx=call_function(kf,fd,g,t0,inx,inPP,t1,nstep,z,QQ,RR,PP=outPP,ZZ=outZZ,KK=outKK,_extra=extra);
  outx[9:12]=outx[9:12]/vlength(outx[9:12]) ;%renormalize estimate of quaternion
  xV [0,*,k]=outx;     % save estimate
  PPV[*,*,k]=outPP;    % save covariance
  ZZV[0,*,k]=outZZ;    % save measurement residual
  KKV[*,*,k]=outKK;    % save Kalman gain
  if k mod 1000 eq 0 then begin
    toc,'At step '+string(k)+' t='+string(tV[k])
    print,'State estimate error (s-x): ',sV[0,*,k]-xV[0,*,k]
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
oplot,xV[0,0,*],xV[0,1,*],psym=0,color=color[i]

swindow,1

titles=['x','y','xd','yd','cd'];
units=['km','km','km/s','km/s','ln(beta)'];

!p.multi=[0,3,2]
for i=0,4 do begin
  plot,tV,abs(sV[0,i,*]-xV[0,i,*,0]),title=titles[i],xtitle='time (s)',ytitle=titles[i]+' ('+units[i]+')',charsize=3
  oplot,tV,abs(sV[0,i,*]-xV[0,i,*]),color=color[j]
  oplot,tV,sqrt(PPV[i,i,*]),color=color[j],linestyle=1
end

toc

end
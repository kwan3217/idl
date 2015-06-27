;+
;Powered Explicit Guidance
;:Params:
;  rv : in, required, type="dblarr(3)"
;      vector position of vehicle in some inertial planetocentric rectangular 
;      frame. This frame is implied, but all vectors should be in this frame.
;      In 2D, a good one has the initial position on the Y axis. In 3D, might
;      as well use ECI or J2000Ecl. Distance units are implied, meters are a
;      good choice.
;  vv : in, required, type="dblarr(3)"
;      vector velocity of vehicle in same frame as r. Time units are implied,
;      seconds are a good choice.
;  a0:in, required, type="double(0)"
;      Acceleration of vehicle at current moment, in same units as r and v
;  v_e:in, required, type="double(0)"
;      Effective velocity of exhaust, sometimes called "Specific impulse", in
;      units of speed implied by units of r and v.
;  r_TT:in, required, type="double(0)"
;      Target distance from planet center at end of powered flight
;  rdot_TT:in, required, type="double(0)"
;      Target vertical speed at end of powered flight
;  TT:in, required, type="double(0)"
;  delta_t:in, required, type="double(0)"
;:Keywords:
;-
pro peg_guide,rv,vv,s,r_TT,rdot_TT,ABT
 
  TT=ABT[2]
  
  r=sqrt(total(rv*rv));Length of r vector. Distance from vehicle to center of planet.
  rdot=total(rv*vv)/r; Component of v in direction of r. Current Vertical speed.
  
  
  ;powered flight integrals
  b_0=s.b(0,TT)
  b_1=s.b(1,TT)
  c_0=s.c(0,TT)
  c_1=s.c(1,TT)
  
  ;Solve simultaneous equation
  ;{rdot_TT=rdot+b_0*AA+b_1*BB
  ;{r_TT   =r+rdot*TT+c_0*AA+c_1*BB
  ; which is equal to 
  ;{rdot_TT-r_dot=b_0*AA+b_1*BB
  ;{r_TT-r-r_dot*TT=c_0*AA+c_1*BB
  ;defining
  k_b=rdot_TT-rdot
  k_c=r_TT-r-rdot*TT
  ;we can then say
  ;M_A##x=M_B
  ;where
  M_B=[k_b,k_c]; known right side of equation
  ;x=[AA,BB];                        the unknown vector
  M_A=[[b_0,b_1],[c_0,c_1]]; Known matrix on left side of equation
  ;and the solution is
  x=LA_LINEAR_EQUATION(M_A,M_B)
  AA=x[0]
  BB=x[1]
  ;Or via Cramer's rule
  BB=(k_c*b_0-c_0*k_b)/(c_1*b_0-c_0*b_1)
  AA=k_b/b_0-b_1/b_0*BB
  ;Check it by plugging back into equations
;  print,rdot+b_0*AA+b_1*BB
;  print,r+rdot*TT+c_0*AA+c_1*BB
  ABT=[AA,BB,TT]   
end

pro peg_navigate,rv,vv,rh=rh,hv=hv,hh=hh,qh=qh
  r=sqrt(total(rv*rv));Length of r vector. Distance from vehicle to center of planet.
  v=sqrt(total(vv*vv));Length of v vector. Current inertial speed of vehicle.
  rh=rv/r; r-hat vector, unit vector parallel to rv
  vh=vv/v; v-hat vector, unit vector parallel to vv
  hv=crossp(rv,vv) ;Specific Angular momentum vector, multiply by vehicle mass to get actual angular momentum
  h=sqrt(total(hv*hv)); Specific angular momentum scalar
  hh=hv/h; Orbit normal vector, unit vector parallel to hv
  qh=crossp(hh,rh) 
  qh=qh/sqrt(total(qh*qh)); Downrange vector, horizontal and in plane of rv and vv
end
  
;PEG burn-time estimate. Given a guidance program and 
;a horizontal velocity target, calculate the time
;required to reach the target
pro peg_estimate,rv,vv,s,mu,deltat,r_TT,vq_TT,ABT
  
  ;--Navigation--
  ;Time update of guidance program
  BB=ABT[1]
  AA=ABT[0]+deltat*BB
  TT=ABT[2]-deltat
  
  ;State vectors, scalars, and basis vectors
  peg_navigate,rv,vv,rh=rh,hh=hh,qh=qh,hv=hv
  r=sqrt(total(rv*rv))
  vq=total(vv*qh); Horizontal velocity at current time
  w=vq/r; Angular velocity \omega at current time
  r=sqrt(total(rv*rv));Length of r vector. Distance from vehicle to center of planet.
  rdot=total(rh*vv); Component of v in direction of r. Current Vertical speed.
  h=sqrt(total(hv*hv)); Specific angular momentum scalar
  
  ;--Estimation--
  h_TT=vq_TT*r_TT; Magnitude of target angular momentum
  deltah=h_TT-h  ;Angular momentum to gain
  
  rbar=(r_TT+r)/2d
  
  CC=(mu/(r*r)-w^2*r)/s.a0; portion of vehicle acceleration used to counter gravity and centrifugal force 
  
  f_r=AA+CC; sin(pitch) at current time
  
  w_TT=vq_TT/r_TT
  a_TT=s.a(TT)
  CC_TT=(mu/(r_TT*r_TT)-w_TT^2*r_TT)/a_TT ; Gravity and centrifugal term at burnout t=TT
  
  f_r_TT=AA+BB*TT+CC_TT ;sin(pitch) at burnout t=TT
  
  fdot_r=(f_r_TT-f_r)/TT ; Approximate speed of sin(pitch) 
  
  f_h=0d;
  fdot_h=0d;
  
  f_q=1d -f_r^2d/2d -f_h^2d/2d ;Approximate cos(pitch)
  fdot_q=-(f_r*fdot_r+f_h*fdot_h) ;Approximate speed of cos(pitch)
  fdotdot_q=-(fdot_r^2d +fdot_h^2d)/2d ;Approximate acceleration of cos(pitch)
  
  deltav_n=deltah/rbar+s.v_e*TT*(fdot_q+fdotdot_q*s.tau)+fdotdot_q*s.v_e*TT^2d/2d
  deltav_d=f_q+fdot_q*s.tau+fdotdot_q*s.tau^2
  
  deltav=deltav_n/deltav_d
  
  TT=s.rocket_t(deltav)
  
  ABT=[AA,BB,TT]
end

pro peg_converge,n,rv,vv,s,mu,r_TT,rdot_TT,vq_TT,abt=abt
  abt=dblarr(n,3)
  abt[0,*]=[0d,0,350]
  for i=1,n-1 do begin
    this_abt=abt[i-1,*]
    peg_guide,rv,vv,s,r_TT,rdot_TT,this_abt
    peg_estimate,rv,vv,s,mu,0,r_tt,vq_tt,this_abt
    abt[i,*]=this_abt
  end
end

function predict_r,r,rdot,s,ABT
  AA=ABT[0]
  BB=ABT[1]
  t=dindgen(ABT[2]+1)
  t[n_elements(t)-1]=ABT[2]
  r_t=r+rdot*t+s.c(0,t)*AA+s.c(1,t)*BB
  rdot_t=rdot+s.b(0,t)*AA+s.b(1,t)*BB
  return,[[r_t],[rdot_t]]
end

function grindout_r,r,rdot,s,ABT
  AA=ABT[0]
  BB=ABT[1]
  t=dindgen(ABT[2]+1)
  t[n_elements(t)-1]=ABT[2]
  r_t=dblarr(n_elements(t))
  r_t[0]=r
  rdot_t=dblarr(n_elements(t))
  rdot_t[0]=rdot
  a_t=s.a(t)
  rdotdot_t=(AA+BB*t)*a_t
  for i=1,n_elements(TT)-1 do begin
    deltat=t[i]-t[i-1]
    rdot_t[i]=rdot_t[i-1]+deltat*rdotdot_t[i]
    r_t[i]=r_t[i-1]+deltat*rdot_t[i]
  end
end

pro fly,rv0,vv0,s,mu,r_TT,rdot_TT,vq_TT,t=t,rv_t=rv_t,vv_t=vv_t,av_t=av_t,a_t=a_t,cc_t=cc_t,fr_t=fr_t,ABT=ABT,inflight_guide=inflight_guide
  peg_converge,100,rv0,vv0,s,mu,r_TT,rdot_TT,vq_TT,abt=abt
  abt0=abt[99,*]  
  t=dindgen(ABT0[2]+1)
  t[n_elements(t)-1]=ABT0[2]
  rv_t=dblarr(n_elements(t),n_elements(rv0))
  rv_t[0,*]=rv0
  vv_t=dblarr(n_elements(t),n_elements(vv0))
  vv_t[0,*]=vv0
  av_t=dblarr(n_elements(t),n_elements(vv0))
  a_t=s.a(t)
  CC_t=dblarr(n_elements(t))  
  fr_t=dblarr(n_elements(t))
  abt=dblarr(n_elements(t),3)
  abt[0,*]=ABT0  
  est_t=0
  for i=1,n_elements(t)-1 do begin
    deltat=t[i]-t[i-1]
    this_abt=abt[i-1,*]
    rv=rv_t[i-1,*]
    vv=vv_t[i-1,*]
    s.burn,deltat
    if keyword_set(inflight_guide) then begin
      peg_estimate,rv,vv,s,mu,deltat,r_TT,vq_TT,this_ABT
      peg_guide,rv,vv,s,r_TT,rdot_TT,this_ABT
;      est_t=
    end
    abt[i,*]=this_abt
    AA=this_abt[0]
    BB=this_abt[1]
    peg_navigate,rv,vv,rh=rh,hh=hh,qh=qh
    r=sqrt(total(rv*rv))
    v=sqrt(total(vv*vv))
    vq=total(vv*qh);
    w=vq/r; Angular velocity \omega
    CC=(mu/(r*r)-w^2*r)/a_t[i]; portion of vehicle acceleration used to counter gravity and centrifugal force
    rdot=total(vv*rh);
    fr=AA+CC;
    CC_t[i]=CC;
    fr_t[i]=fr;
    fq=sqrt(1-fr^2);
    if ~finite(fq) then message,"Uh oh"
    f=fr*rh+fq*qh;
    av_t[i,*]=f*a_t[i]-mu*rv/(r^3);
    vv_t[i,*]=vv_t[i-1,*]+deltat*av_t[i,*]
    rv_t[i,*]=rv_t[i-1,*]+deltat*vv_t[i,*]
  end
end

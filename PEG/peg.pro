;+
; :Description:
;    Vehicle acceleration curve
;
; :Params:
;    a0 : in, required, type=double
;      Vechicle ideal acceleration (thrust divided by mass) at time t=0, implies
;      units of distance and time (m/s^2 is a good choice)
;    t :in, required, type=double
;      Time at which to calculate acceleration, units of time from a0
;    tau: in, required, type=double
;      Normalized vehicle mass, units of time from a0
;      
; :Returns:
;   Acceleration of vehicle at time t, in same units as a0
;-
function a,a0,t,tau
  return,a0/(1-t/tau)
end

;+
;Powered flight speed integral and moments thereof.
;
;Calculates \int_0^{TT}{t^n a(t)dt}. When n=0, this is the
;accumulated ideal speed -- in other words this is the mass normalized form of 
;the rocket equation. Higher moments are needed in the PEG problem.
;
;:Params:
;  n : in, required, type=int
;    Moment of integral to calculate
;  TT : in, required, type=double
;    Upper bound of integration, in units of time. This variable implies the 
;    time units used in the problem. Seconds is a good choice.
;  v_e: in, required, type=double
;    Effective exhaust velocity, in units of speed. This variable implies the
;    distance units used in the problem
;  tau: in, required, type=double
;    normalized mass, tau=v_e/a0, in units of time, must be in same time units
;    implied by TT.
;    
; :Returns:
;    Value of speed integral. Dimension is (L/T)T^n, L/T for n=0. Units for L and T
;    are those implied by input units.
;-
function b,n,TT,v_e,tau
  if(n eq 0) then return,-v_e*alog(1-TT/tau)
  return,b(n-1,TT,v_e,tau)*tau-v_e*TT^double(n)/double(n)
end

;+
;Powered flight distance integral and moments thereof.
;
;Calculates \int_0^{TT}b(t)dt=\int_0^{TT}\int_0^{t}{s^n a(s)ds}dt, the integral 
;of b(n) with respect to time. When n=0, this is the accumulated distance 
;traveled. Higher moments are needed in the PEG problem.
;
;:Params:
;  n : in, required, type=int
;    Moment of integral to calculate
;  TT : in, required, type=double
;    Upper bound of integration, in units of time. This variable implies the 
;    time units used in the problem. Seconds is a good choice.
;  v_e: in, required, type=double
;    Effective exhaust velocity, in units of speed. This variable implies the
;    distance units used in the problem
;  tau: in, required, type=double
;    normalized mass, tau=v_e/a0, in units of time.
;:Returns:
;  value of distance integral, LT^n, L for n=0
;-
function c,n,TT,v_e,tau
  if(n eq 0) then return,b(0,TT,v_e,tau)*TT-b(1,TT,v_e,tau)
  return,c(n-1,TT,v_e,tau)*tau-v_e*TT^double(n+1)/double(n*(n+1))
end

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
pro peg_guide,rv,vv,a0,v_e,r_TT,rdot_TT,ABT
  ;Vehicle normalized mass tau
  tau=v_e/a0
  
  TT=ABT[2]
  
  r=vlength(rv);Length of r vector. Distance from vehicle to center of planet.
  rdot=dotp(rv,vv)/r; Component of v in direction of r. Current Vertical speed.
  
  
  ;powered flight integrals
  b_0=b(0,TT,v_e,tau)
  b_1=b(1,TT,v_e,tau)
  c_0=c(0,TT,v_e,tau)
  c_1=c(1,TT,v_e,tau)
  
  ;Solve simultaneous equation
  ;{rdot_TT=rdot+b_0*AA+b_1*BB
  ;{r_TT   =r+rdot*TT+c_0*AA+c_1*BB
  ; which is equal to 
  ;{rdot_TT-r_dot=b_0*AA+b_1*BB
  ;{r_TT-r-r_dot*TT=c_0*AA+c_1*BB
  ;Defining
  k_b=rdot_TT-rdot
  k_c=r_TT-r-rdot*TT
  ;we can then say
  ;M_A##x=M_B
  ;where
  M_B=[k_b,k_c]; known right side of equation
  ;x=[AA,BB];     the unknown vector
  M_A=[[b_0,b_1],[c_0,c_1]]; Known matrix on left side of equation
  ;and the solution is
  ;x=LA_LINEAR_EQUATION(M_A,M_B)
  ;AA=x[0]
  ;BB=x[1]
  ;Or via Cramer's rule
  BB=(k_c*b_0-c_0*k_b)/(c_1*b_0-c_0*b_1)
  AA=k_b/b_0-b_1/b_0*BB
  ;Check it by plugging back into equations
  ;print,rdot+b_0*AA+b_1*BB
  ;print,r+rdot*TT+c_0*AA+c_1*BB
  ABT=[AA,BB,TT]   
end

pro peg_navigate,rv,vv,rh=rh,hv=hv,hh=hh,qh=qh
  r=vlength(rv);Length of r vector. Distance from vehicle to center of planet.
  v=vlength(vv);Length of v vector. Current inertial speed of vehicle.
  rh=rv/r; r-hat vector, unit vector parallel to rv
  vh=vv/v; v-hat vector, unit vector parallel to vv
  hv=crossp(rv,vv) ;Specific Angular momentum vector, multiply by vehicle mass to get actual angular momentum
  h=vlength(h); Specific angular momentum scalar
  hh=hv/h; Orbit normal vector, unit vector parallel to hv
  qh=normalize_grid(crossp(hh,rh)); Downrange vector, horizontal and in plane of rv and vv 
end
  
;PEG burn-time estimate. Given a guidance program and 
;a horizontal velocity target, calculate the time
;required to reach the target
pro peg_estimate,rv,vv,a0,v_e,mu,deltat,r_TT,vq_TT,ABT
  
  ;--Navigation--
  ;Time update of guidance program
  BB=ABT[1]
  AA=ABT[0]+deltat*BB
  TT=ABT[2]-deltat
  
  ;State vectors, scalars, and basis vectors
  peg_navigate,rv,vv,rh=rh,hh=hh,qh=qh,hv=hv
  tau=v_e/a0
  r=vlength(rv)
  vq=dotp(vv,qh); Horizontal velocity at current time
  w=vq/r; Angular velocity \omega at current time
  r=vlength(rv);Length of r vector. Distance from vehicle to center of planet.
  rdot=dotp(rh,vv); Component of v in direction of r. Current Vertical speed.
  h=vlength(hv); Specific angular momentum scalar
  
  ;--Estimation--
  h_TT=vq_TT*r_TT; Magnitude of target angular momentum
  deltah=h_TT-h  ;Angular momentum to gain
  
  rbar=(r_TT+r)/2d
  
  CC=(mu/(r*r)-w^2*r)/a0; portion of vehicle acceleration used to counter gravity and centrifugal force 
  
  f_r=AA+CC; sin(pitch) at current time
  
  w_TT=vq_TT/r_TT
  a_TT=a(a0,TT,tau)
  CC_TT=(mu/(r_TT*r_TT)-w_TT^2*r_TT)/a_TT ; Gravity and centrifugal term at burnout t=TT
  
  f_r_TT=AA+BB*TT+CC_TT ;sin(pitch) at burnout t=TT
  
  fdot_r=(f_r_TT-f_r)/TT ; Approximate speed of sin(pitch) 
  
  f_h=0d;
  fdot_h=0d;
  
  f_q=1d -f_r^2d/2d -f_h^2d/2d ;Approximate cos(pitch)
  fdot_q=-(f_r*fdot_r+f_h*fdot_h) ;Approximate speed of cos(pitch)
  fdotdot_q=-(fdot_r^2d +fdot_h^2d)/2d ;Approximate acceleration of cos(pitch)
  
  deltav_n=deltah/rbar+v_e*TT*(fdot_q+fdotdot_q*tau)+fdotdot_q*v_e*TT^2d/2d
  deltav_d=f_q+fdot_q*tau+fdotdot_q*tau^2
  
  deltav=deltav_n/deltav_d
  
  TT=tau*(1-exp(-deltav/v_e))
  ABT=[AA,BB,TT]
end

pro peg_converge,n,rv,vv,a0,v_e,mu,r_TT,rdot_TT,vq_TT,abt=abt
  abt=dblarr(n,3)
  abt[0,*]=[0d,0,350]
  for i=1,n-1 do begin
    this_abt=abt[i-1,*]
    peg_guide,rv,vv,a0,v_e,r_TT,rdot_TT,this_abt
    peg_estimate,rv,vv,a0,v_e,mu,0,r_tt,vq_tt,this_abt
    abt[i,*]=this_abt
  end
end

function predict_r,r,rdot,a0,v_e,ABT
  AA=ABT[0]
  BB=ABT[1]
  tau=v_e/a0
  t=dindgen(ABT[2]+1)
  t[n_elements(t)-1]=ABT[2]
  r_t=r+rdot*t+c(0,t,v_e,tau)*AA+c(1,t,v_e,tau)*BB
  rdot_t=rdot+b(0,t,v_e,tau)*AA+b(1,t,v_e,tau)*BB
  return,[[r_t],[rdot_t]]
end

function grindout_r,r,rdot,a0,v_e,ABT
  AA=ABT[0]
  BB=ABT[1]
  t=dindgen(ABT[2]+1)
  t[n_elements(t)-1]=ABT[2]
  tau=v_e/a0
  r_t=dblarr(n_elements(t))
  r_t[0]=r
  rdot_t=dblarr(n_elements(t))
  rdot_t[0]=rdot
  a_t=a(a0,t,tau)
  rdotdot_t=(AA+BB*t)*a_t
  for i=1,n_elements(TT)-1 do begin
    deltat=t[i]-t[i-1]
    rdot_t[i]=rdot_t[i-1]+deltat*rdotdot_t[i]
    r_t[i]=r_t[i-1]+deltat*rdot_t[i]
  end
end

pro fly,rv0,vv0,a0,v_e,mu,ABT
  AA=ABT[0]
  BB=ABT[1]
  t=dindgen(ABT[2]+1)
  t[n_elements(t)-1]=ABT[2]
  tau=v_e/a0
  rv_t=dblarr(n_elements(t),n_elements(rv0))
  rv_t[0,*]=rv0
  vv_t=dblarr(n_elements(t),n_elements(vv0))
  vv_t[0,*]=vv0
  av_t=dblarr(n_elements(t),n_elements(vv0))
  a_t=a(a0,t,tau)
  CC_t=dblarr(n_elements(t))  
  fr_t=dblarr(n_elements(t))  
  for i=1,n_elements(t)-1 do begin
    deltat=t[i]-t[i-1]
    rv=rv_t[i-1,*]
    vv=vv_t[i-1,*]
    peg_navigate,rv,vv,rh=rh,hh=hh,qh=qh
    r=vlength(rv)
    v=vlength(vv)
    qdot=dotp(vv,qh);
    w=qdot/r; Angular velocity \omega
    CC=(mu/(r*r)-w^2*r)/a_t[i]; portion of vehicle acceleration used to counter gravity and centrifugal force
    rdot=dotp(vv,rh);
    fr=AA+BB*t[i]+CC;
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

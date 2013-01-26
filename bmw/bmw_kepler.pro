;Given a state vector and time interval, calculate the state after the time interval elapses
;input
;  rv0  - position vector relative to central body
;  vv0  - velocity vector relative to central body
;  t    - time interval from given state to requested state - may be negative
;  l_DU=- optional - used to convert rv0 and vv0 to canonical units. Length of distance canonical
;         unit in standard units implied by rv0. If not set, input state and time are already
;         presumed to be in canonical units
;  mu=  - optional, but required if l_DU= is set - used to convert to canonical units. Gravitational
;         constant in standard units
;  eps= - optional - loop termination criterion, default to 1e-9
;output
;  rv_t= - Position vector after passage of time t, in same units as rv0 
;  vv_t= - Velocity vector after passage of time t, in same units as vv0
pro bmw_kepler,rv0_,vv0_,t_,l_DU=l_DU,mu=mu,rv_t=rv_t,vv_t=vv_t,eps=eps
  tau=!dpi*2d
  if n_elements(eps) eq 0 then eps=1d-9
  if keyword_set(l_du) then begin
    rv0=su_to_cu(rv0_,l_du,mu,1,0)
    vv0=su_to_cu(vv0_,l_du,mu,1,-1)
    t=su_to_cu(t_,l_du,mu,0,1)
  end else begin
    rv0=rv0_
    vv0=vv0_
    t=t_
  end

  r0=vlength(rv0)
  v0=vlength(vv0)
  
  r0dv0=dotp(rv0,vv0)
  
  ;Determine specific energy, and thereby the orbit shape
  ;These are dependent on the initial state and therefore scalar
  E=v0^2/2d -1d/r0
  alpha=-2*E ;alpha is 1/a, reciprocal of semimajor axis (in case of parabola. a can be infinite, but never zero
  
  ;Starting guess for x - x0 will be same shape as t
  if(alpha gt 0) then begin
    ;elliptical
    x0=t*alpha
  end else if alpha eq 0 then begin
    ;parabolic (this will never really happen)
    hv=crossp_grid(rv0,vv0)
    p=total(hv*hv)
    ;acot(x)=tau/4-atan(x)
    s=(tau/4d -atan(3d*t*sqrt(1d/p^2d)))/2d
    w=atan(tan(s)^(1d/3d))
    x0=sqrt(p)/tan(2*w) ;cot(x)=1/tan(x)
  end else begin
    ;hyperbolic
    sa=sqrt(1d/alpha)
    st=(t gt 0) ? 1 : -1
    x0_a=st*sa
    x0_n=-2*alpha*t
    x0_d=r0dv0+st*sa*(1-r0*alpha)
    x0=x0_a*alog(x0_n/x0_d)
  end
  done=0
  xn=x0
  while ~done do begin
    z=xn^2*alpha
    C=bmw_CC(z)
    S=bmw_SS(z)
    r=xn^2*C+r0dv0*xn*(1-z*S)+r0*(1d -z*C)
    tn=xn^3*S+r0dv0*xn^2*C+r0*xn*(1d -z*S)
    xnp1=xn+(t-tn)/r
    done=min(abs(xn-xnp1) lt eps)
    xn=xnp1
  end
  x=xn
  f=1-x^2*C/r0
  g=t-x^3*s
  fdot=x*(z*S-1)/(r*r0)
  gdot=1-x^2*C/r
  rv_t=compose_grid(f   *rv0[0]+g   *vv0[0],f   *rv0[1]+g   *vv0[1],f   *rv0[2]+g   *vv0[2])
  vv_t=compose_grid(fdot*rv0[0]+gdot*vv0[0],fdot*rv0[1]+gdot*vv0[1],fdot*rv0[2]+gdot*vv0[2])
  if keyword_set(l_du) then begin
    rv_t=su_to_cu(rv_t,l_du,mu,1,0,/inv)
    vv_t=su_to_cu(vv_t,l_du,mu,1,-1,/inv)
  end
end  
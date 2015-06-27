;Calculate impact parameter B from gravity parameter of planet and
;entry interface conditions
;input
;  mu - gravity parameter of target planet. Implies units of distance and time
;  r_ei - Entry interface distance from center of planet in distance units implied by mu
;  fpa_ei - inertial flight path angle at entry interface in radians, negative is downward (usual case) 
;  v_ei= - inertial speed at entry interface in distance and time units implied by mu
;  v_inf= - hyperbolic excess speed, in distance and time units implied by mu
; One or the other of v_ei= and v_inf= must be passed as input, the other is calculated and returned as output
; if both are passed in, v_inf is recalculated from v_ei
;output
;  v_ei= or v_inf= - one must be passed in, the other is calculated and passed out
;  ta_inf - true anomaly at infinity in radians, always negative
;  ta_ei - true anomaly at entry interface altitude in radians, always negative
;  dt_ei_rp - time from entry interface to theoretical periapse, ignoring aerobraking and lithobraking
;return
;  impact parameter B - distance from center of planet to hyperbolic asymtote in 
;  distance units implied by mu
function b_from_ei,mu,r_ei,fpa_ei,v_ei=v_ei,v_inf=v_inf,ta_inf=ta_inf,ta_ei=ta_ei,dt_ei_rp=dt_ei_rp,rp=rp
  tau=!dpi*2 ;Tau manifesto
  if n_elements(v_ei) ne 0 then begin
    xi=v_ei^2/2-mu/r_ei
    a=-mu/(2*xi)
    v_inf=sqrt(-mu/a)
  end else begin
    ; specific energy at infinity, remembering that potential energy is
    ; zero at infinity and is negative at finite distance
    xi=v_inf^2/2
    a=-mu/(2*xi)
    v_ei=sqrt(2*mu/r_ei-mu/a)
  end
  h=r_ei*v_ei*sin(tau/4d -fpa_ei) ;magnitude of cross product a x b is a*b*sin(theta)
  p=h^2/mu
  e=sqrt(1d +(2d*xi*h^2)/(mu^2))
  rp=a*(1d -e)
  B=rp*sqrt((2d*mu)/(rp*v_inf^2)+1d)
  ta_ei=-acos(p/(r_ei*e)-1d/e)
  ta_inf=-acos(-1/e)

  shEE=sin(ta_ei)*sqrt(e^2-1)/(1d +e*cos(ta_ei))
  MM=e*shEE-asinh(shEE)
  n=sqrt(-mu/(a^3))
  dt_ei_rp=MM/n
  return,b
end
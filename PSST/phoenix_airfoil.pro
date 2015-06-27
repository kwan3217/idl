;calculate force and moment from airfoil
;input
;  vwind_i - velocity of vehicle relative to local air in some inertial frame
;  ei2b    - Quaternion which converts inertial vectors to body via r_b=e'*r_i*e
;  rho     - atmosphere density at this point, in kg/m^3 (water=1000)
;  csound  - speed of sound in m/s
;output
;  f=      - force produced by airfoil in body coordinates, in N
;  torque= - pure torque produced by airfoil in body coordinates, not counting moment arm of f= above, in N*m
;  coa=    - center of action of force in station coordinates, in m
pro phoenix_airfoil,vwind_i,ei2b,rho,csound,f=f,torque=torque,coa=coa
  vwind_b=transformgrid(ei2b,vwind_i)
  alpha_t=vangle(vwind_b,[1,0,0])
  coa=[-1.07d,0,0]
  M=vlength(vwind_b)/csound
  q=vlength(vwind_b)^2*rho/2d
;  vwind_b=[u,v,w]=velocity of airfoil with respect to local air (not velocity of air with respect to airfoil, which is the negative of this vector) in airfoil frame
;  beta=atan2(v/u) ;equivalent to longitude
;  alpha=atan2(w*cos(beta)/u)
;  alpha_t=acos(cos(alpha)*cos(beta))
    
  aeroshell_70deg,M,alpha_t,CdA=CdA,ClA=ClA,CmAD=CmAD,CmwAD=CmwAD,D=D
  
end

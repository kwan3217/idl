function quat_interp,t0,q0,t1,q1,t
;
;-------------------------------------------------------------------------------
; Procedure: quat_interp
;
; Purpose: This routine will interpolate between the two input points
;	   to provide the quaternion at the input time
;
; Author:  Brian Boyle - LASP/CU - November 14, 1996
;
; Inputs: t0 - first time
;	  q0 - first quaternion array(4)
;	  t1 - last time
;	  q1 - last quaternion array(4)
;	  t - time to interpolate to
;
; Outputs: q - interpolated quaternion
;
; Keywords:  none
;
; Files Accessed: none
;
;-------------------------------------------------------------------------------
;
; Check input parameters...
; 
if n_params() ne 5 then begin
  message,/info,'USAGE: result=quat_interp (t0,q0,t1,q1,t)'
  return,-1
endif
;
; Get new quaternion
;
q = quat_mult(quat_invert(q0),(q1))
;
; Get rotation angle of new vector
;
phi = dacos( q(3) ) * 2d
if phi eq 0 then return,q0
;
; Get new v
;
v=q(0:2)/sin(phi/2d)
; normalize v
vmag=sqrt(total(v*v))
v=v/vmag
;
; Interpolate phi to the new time
;
dif = double(t1-t0)
rdif= double(t -t0)
if dif eq 0 then return,q0
new_phi = (rdif/dif)*phi
;
; Get new q 
;
q=[v*sin(new_phi/2d),cos(new_phi/2d)]
;
; Normalize q
;
qmag=sqrt(total(q*q))
q=q/qmag
;
; Final q
;
q=quat_mult(quat_invert(q),quat_invert(q0))
;
; Done
;
return,q
end

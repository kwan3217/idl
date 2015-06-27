function quat_vect_mult,q,v
;
;-------------------------------------------------------------------------------
; Procedure: quat_vect_mult
;
; Purpose: Translate input vector, V through transfomation quaternion, q
;
; Author: Brian Boyle - LASP/CU - November 14, 1996
;
; Inputs: q - dblarr(4) - single transformation quaternion (euler parameters)
;     v - dblarr(*,*,3) - vector grid to be transformed
;
; Outputs: result - dblarr(*,*,3) - transformed vector
;
; Keywords: none
;
; Files Accessed: none
;
;-------------------------------------------------------------------------------
;
; Check input parameters...
;
if n_params() ne 2 then begin
  message,/info,'USAGE: result=quat_vect_mult(q,v)'
  return,-1
endif
;
; Compute transformation
;
e4=q[3]
e=q[0:2]
result= v + 2d*( e4*crossp_grid(e,v) + crossp_grid(e,crossp_grid(e,v)) )
;
; Done
;
return,result
end

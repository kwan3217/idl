function quat_invert,q
;
;-------------------------------------------------------------------------------
; Procedure: quat_invert
;
; Purpose: Invert the input quaternion. This operation is commonly called
;          "quaternion conjugation" and is only really a quaternion inverse
;          for a normalized quaternion. Since that's what we use almost
;          exclusively, that's ok.
;
; Author:  Brian Boyle LASP/CU - November 14, 1996
;          Modified to handle quaternion grids in
;
; Inputs: q - fltarr(4) quaternion to invert
;
; Outputs: q_inverse - fltarr(4) inverse of q
;
; Keywords: none
;
; Files Accessed: none
;
;-------------------------------------------------------------------------------
;
; Check input parameters...
;
if n_params() ne 1 then begin
  message,/info,'USAGE: result = quat_invert(q)'
  return,-1
endif
;
; Invert quaternion
;
resolve_grid,q,x=x,y=y,z=z,w=w
q_inverse=compose_grid(-x,-y,-z,w)
;
; Done
;
return,q_inverse
end

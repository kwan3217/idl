function quat_mult_grid,q1,q2
;
;-------------------------------------------------------------------------------
; Procedure: quat_mult
;
; Purpose: This routine multiplys the two input quaternions
;
; Author:  Brian Boyle LASP/CU November 14, 1996
;
; Inputs: q1 - fltarr(4) - first quaternion
;   q2 - fltarr(4) - second quaternion
;
; Outputs: q - fltarr(4) - result of q1*q2
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
  message,/info,'USAGE: result = quat_mult(q1,q2)'
  return,-1
endif

;
; Multiply Quaternions
;
;if size(q1,/n_dimensions) eq 1 then begin
;  q=quat_mult(q2,q1) ;Bring quaternion multiplication back into conformity with convention
;end else begin
  resolve_grid,q1,x=Ax,y=Ay,z=Az,w=A0
  resolve_grid,q2,x=Bx,y=By,z=Bz,w=B0
  C0=A0*B0-Ax*Bx-Ay*By-Az*Bz
  Cx=A0*Bx+Ax*B0+Ay*Bz-Az*By
  Cy=A0*By-Ax*Bz+Ay*B0+Az*Bx
  Cz=A0*Bz+Ax*By-Ay*Bx+Az*B0
  q=compose_grid(Cx,Cy,Cz,C0)
;end
;
; Done
;
return,q
end

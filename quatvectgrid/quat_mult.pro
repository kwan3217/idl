function quat_mult,q1,q2
;
;-------------------------------------------------------------------------------
; Procedure: quat_mult
;
; Purpose: This routine multiplys the two input quaternions
;
; Author:  Brian Boyle LASP/CU November 14, 1996
;
; Inputs: q1 - fltarr(4) - first quaternion
;	  q2 - fltarr(4) - second quaternion
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
q = [[q1(3),-q1(2),q1(1),-q1(0)],[q1(2),q1(3),-q1(0),-q1(1)],$
     [-q1(1),q1(0),q1(3),-q1(2)],[q1(0),q1(1),q1(2),q1(3)]]#q2
;
; Done
;
return,q
end

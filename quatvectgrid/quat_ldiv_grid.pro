function quat_ldiv_grid,q1,q2
;
;-------------------------------------------------------------------------------
; Procedure: quat_mult
;
; Purpose: This routine divides the two input quaternions. In other words,
;          given two known quaternions q1 and q2, find the quaternion qx which
;          satisfies the relation q1*qx=q2. This is found using the quaternion
;          inverse function.
;
;                q1*qx      =      q2
;          q1^-1*q1*qx      =q1^-1*q2   (left Multiply both sides by inverse of q1)
;                   qx      =q1   \q2
;
; Author:  Chris Jeppesen / 6 October 2006
;
; Inputs: q1 - first quaternion. May be a grid
;         q2 - second quaternion. May be a grid, but must be compatible with q1
;
; Outputs: q - result of q1\q2
;
; Keywords: none
;
; Files Accessed: none
;
return,quat_mult_grid(quat_invert(q1),q2)
end

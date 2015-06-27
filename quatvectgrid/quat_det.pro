function quat_det,pA,qA,pB,qB
;
;-------------------------------------------------------------------------------
; Function: quat_det
;
; Purpose: Given two position vectors in frame A (pA, qA) and two position 
;  vectors (of the same body) in frame B (pB, qB) this function determines the
;  quaternion describing the rotation of frame A to frame B
;
; Author: B.Boyle (CU/LASP) 3/16/00
;
; Inputs: 
;	 pA - fltarr(3) describes first point in Frame A
;	 qA - fltarr(3) describes second point in Frame A
;	 pB - fltarr(3) describes first point in Frame B 
;	 qB - fltarr(3) describes second point in Frame B
;
; Outputs: 
;
; Keywords: 
;
; Files Accessed: none
;
; Referrences: See pp21-23 "Spacecraft Dynamics" Kane, Likins, Levinson
;
;-------------------------------------------------------------------------------
;
; Check input parameters...
; 
if n_params() ne 4 then begin
  message,/info,'USAGE: result=quat_det(pA,qA,pB,qB)'
  return,-1
endif
;
; Declarations...
;
ra= crossp(pA,qA)
rb= crossp(pB,qB)
qxr=crossp(qa,ra)
rxp=crossp(ra,pa)
r2= total(rA^2)
;
; Useful matrices
;
sigA=transpose([[rA],[qxr],[rxp]])
sigB=transpose([[rB], [pB], [qB]])
;
; From rotation matrix
;
c11=total( (sigA#[1,0,0])*(sigB#[1,0,0]) )/r2
c12=total( (sigA#[1,0,0])*(sigB#[0,1,0]) )/r2
c13=total( (sigA#[1,0,0])*(sigB#[0,0,1]) )/r2
c21=total( (sigA#[0,1,0])*(sigB#[1,0,0]) )/r2
c22=total( (sigA#[0,1,0])*(sigB#[0,1,0]) )/r2
c23=total( (sigA#[0,1,0])*(sigB#[0,0,1]) )/r2
c31=total( (sigA#[0,0,1])*(sigB#[1,0,0]) )/r2
c32=total( (sigA#[0,0,1])*(sigB#[0,1,0]) )/r2
c33=total( (sigA#[0,0,1])*(sigB#[0,0,1]) )/r2
;
; Done
;
return,quat_to_mtx([[c11,c12,c13],[c21,c22,c23],[c31,c32,c33]],/inverse)
end

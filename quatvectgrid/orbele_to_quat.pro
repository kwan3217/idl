function orbele_to_quat,inc=inc,node=node,omega=omega
;
;-------------------------------------------------------------------------------
; Procedure: orbele_to_quat
;
; Purpose: Converts input orbital parameters to a transformation quaternion.
;	   assumes a circular orbit (ecc=0) and arg of (periapse = 0)
;
; Author: Brian Boyle 
;
; Inputs: optional orbital parameters taken as zero if not given
;
; Outputs: 
;
; Keywords:	inc - orbital inclination (degrees) 
;		node - right ascention of the ascending node(degrees) 
;	   	omega - orbital angle measured from ascending node (degrees) 
;
; Files Accessed: none
;
;-------------------------------------------------------------------------------
;
; Check input parameters...
; 
if keyword_set(help) then begin
  message,/info,'USAGE: result=orbele_to_quat(inc=inc,node=node,omega=omega,/help)'
endif
;
; Declarations...
;
if not(keyword_set(inc)) then i=0.0 else i=inc*!dtor
if not(keyword_set(node)) then n=0.0 else n=node*!dtor
if not(keyword_set(omega)) then w=0.0 else w=omega*!dtor
;
; Fill in matrix elements
;
m11=  cos(w)*cos(n) - sin(w)*sin(n)*cos(i)
m21=  cos(w)*sin(n) + sin(w)*cos(n)*cos(i)
m31=  sin(i)*sin(w)
m12= -sin(w)*cos(n) - sin(n)*cos(i)*cos(w)
m22= -sin(w)*sin(n) + cos(n)*cos(i)*cos(w)
m32=  sin(i)*cos(w)
m13=  sin(i)*sin(n)
m23= -sin(i)*cos(n)
m33=  cos(i)
m=transpose([[m11,m21,m31],[m12,m22,m32],[m13,m23,m33]])
;
; Rotate into (X,Y,Z) => (V,R,*) coordinate system
;
m=[[0,0,-1],[1,0,0],[0,-1,0]]#m
;
; Done
;
return,quat_to_mtx(m,/inverse)
end

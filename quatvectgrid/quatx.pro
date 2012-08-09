;Function: QuatX.pro
;Author:   Chris Jeppesen
;Date:     7 Jul 2005
;Returns a rotation matrix for a rotation about a given primary axis by a given angle
;Performs a right-handed rotation. In other words, if the thumb of the right hand points
;towards the positive sense of the axis, the fingers curl in the direction of positive
;rotation. Think of it as transforming the vector, not the coordinate system
;
;In parameters:
;  X:     Axis to rotate around, 1=X, 2=Y, 3=Z
;  theta: Angle to rotate, radians
;
;Return:
;  A quaternion which will transform the vector
;
;Example:
;IDL> print,RotX(3,!dpi/6)##[[1],[0],[0]] ;Rotate (1,0,0) by 30 degrees around the Z axis
;  0.86602540
;  0.50000000
;  0.00000000
;IDL> print,quat_vect_mult(QuatX(3,!dpi/6),[1,0,0]) ;Rotate (1,0,0) by 30 degrees around the Z axis
;  0.86602540  0.50000000  0.00000000
function QuatX,X,theta
  axis=[0,0,0]
  axis[X-1]=1;
  return,axis_angle_to_quat(axis,theta)
end
function ana_to_quat,axis,angle
;
;-------------------------------------------------------------------------------
; Procedure: quat_to_ana
;
; Purpose: Get the axis-and-angle representation of a quaternion.
;
; Author:  Chris Jeppesen / 6 October 2006
;
; Inputs: q - A normalized quaternion. May be a grid
;
; Outputs: Axis - Axis of rotation. Will be a grid if q is a grid
;          Angle - Angle of rotation, in radians. Will be an array if
;                  q is a grid
  v=axis*sin(angle/2)
  w=cos(angle/2)
  resolve_grid,v,x=x,y=y,z=z
  return,compose_grid(x,y,z,w)
end

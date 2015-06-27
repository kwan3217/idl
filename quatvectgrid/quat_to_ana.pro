pro quat_to_ana,q,axis=axis,angle=angle
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

  resolve_grid,q,x=x,y=y,z=z,w=w,/has_w
  angle=2*acos(w)
  S=sin(angle/2)
  x/=s
  y/=s
  z/=s
  axis=compose_grid(x,y,z)
end

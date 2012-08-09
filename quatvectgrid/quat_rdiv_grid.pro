function quat_rdiv_grid,q1,q2
;
;-------------------------------------------------------------------------------
; Procedure: quat_rdiv_grid
;
; Purpose: This routine divides the two input quaternions. In other words,
;          given two known quaternions q1 and q2, find the quaternion qx which
;          satisfies the relation qx*q1=q2. This is found using the quaternion
;          inverse function.
;
;          qx*q1      =q2
;          qx*q1*q1^-1=q2*q1^-1   (right Multiply both sides by inverse of q1)
;          qx         =q2/q1
;
;          An application of this function is as follows: Suppose you know
;          some starting frame relative to the reference, expressed in q1, and some
;          final frame expressed in q2. What is the additional rotation qx which is
;          required to bring a vector in the first frame into the second frame?
;
;          Or even more concrete: A spacecraft has an orientation described by q1
;          at some time, and later has a new orientation q2. What maneuver did it
;          perform? You can find this by quat_rdiv_grid, followed by a
;          transformation of the quaternion into Axis-Angle form.
;
; Author:  Chris Jeppesen / 6 October 2006
;
; Inputs: q1 - first quaternion. May be a grid
;         q2 - second quaternion. May be a grid, but must be compatible with q1
;
; Outputs: q - result of q1/q2

return,quat_mult_grid(q2,quat_invert(q1))

end

Function crossp_grid,a,b
;
;+
; NAME:
;   CROSSP
;
; PURPOSE:
;   Evaluates the cross product of v1 with v2
;
; CATEGORY:
;   Vector mathematics.
;
; CALLING SEQUENCE:
;   Result = CROSSP(v1, v2)
;
; INPUTS:
;   v1, v2:  Three-element vectors.
;
; OUTPUTS:
;   Returns a 3-element, floating-point vector.
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;   None.
;
; RESTRICTIONS:
;   Vectors must have 3 elements.
;
; PROCEDURE:
;   v1 X v2 = | i  j  k  | = (b1c2 - b2c1)i + (c1a2-c2a1)j + (a1b2-a2b1)k
;       | a1 b1 c1 |
;       | a2 b2 c2 |
;
; MODIFICATION HISTORY:
;   Written, DMS, Aug, 1983;
;   Modified by Chris Jeppesen, Jul, 2005 to multiply a whole grid
;-

    resolve_grid,a,x=ax,y=ay,z=az
    resolve_grid,b,x=bx,y=by,z=bz
 
    x=ay*bz-az*by
    y=az*bx-ax*bz
    z=ax*by-ay*bx

    return,compose_grid(x,y,z)
end

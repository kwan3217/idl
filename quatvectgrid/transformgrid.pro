;Use a transformation structure to transform a vector or grid of vectors
;
; Input
;   T - Either a 3x3 array representing a transformation matrix, or a
;       4 element vector representing a quaternion
;   V - Either a 3 element vector, or an Nx3 element array where each
;       row represents a vector, or a ...x3 element grid, where each
;       grid cell represents a vector as used in resolve_grid
;
; Returns
;   A vector or grid of vectors representing the original input transformed
;   by the transformation structure.
function TransformGrid,T,V
  if(n_elements(T) eq 9) then begin
    ;It's a matrix
    return,V ## T
  end else begin
    ;It's a quaternion
    return,quat_vect_mult(T,V);
  end
end

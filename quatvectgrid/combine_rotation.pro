function combine_rotation,T1,T2
  if(n_elements(T1) ne n_elements(T2)) then begin
    message,/error,'Two transformations of different type'
    return,-1
  end

  if(n_elements(T2) eq 9) then begin
    ;It's a matrix
    return,T2 ## T1
  end else begin
    ;It's a quaternion
    return,quat_mult(T1,T2);
  end
end
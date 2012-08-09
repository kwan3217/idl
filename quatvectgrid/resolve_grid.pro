pro resolve_grid,v,x=x,y=y,z=z,w=w,n_dimension_vec=n_dimension_vec
  s=size(v,/dim)
  ndims=n_elements(s)-1
  n_dimension_vec=s[ndims]
  case ndims of
    -1: begin
          message,"Must pass a vector or grid of vectors"
          return
        end
    0:  begin
          if n_dimension_vec ge 1 then x=v[0];
          if n_dimension_vec ge 2 then y=v[1];
          if n_dimension_vec ge 3 then z=v[2];
          if n_dimension_vec ge 4 then w=v[3];
        end
    1:  begin
          if n_dimension_vec ge 1 then x=v[*,0];
          if n_dimension_vec ge 2 then y=v[*,1];
          if n_dimension_vec ge 3 then z=v[*,2];
          if n_dimension_vec ge 4 then w=v[*,3];
        end
    2:  begin
          if n_dimension_vec ge 1 then x=v[*,*,0];
          if n_dimension_vec ge 2 then y=v[*,*,1];
          if n_dimension_vec ge 3 then z=v[*,*,2];
          if n_dimension_vec ge 4 then w=v[*,*,3];
        end
    else: begin
          message,"Unsupported grid dimension"
        end
  endcase

end

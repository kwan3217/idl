;A Grid is a multidimensional array of vectors. It is inconvenient to talk about
;an array of things which themselves are arrays, so it's a grid.
;
;A grid of vectors can have any number of dimensions, but the last dimension
;is the vector component index. So, a grid would typically look like v[i,j,3].
;Even though this is a 3D array, it is only a 2D grid of vectors.
;
;A grid can have any number of dimensions, but if more than three are needed, this function
;and resolve_grid will need to be extended.
;
;This function takes three arrays of scalars of the same size and shape, and builds a grid
;of vectors with the same size and shape. Each input array becomes one vector component.
function compose_grid,x,y,z,w
  ndims=size(x,/n_dimensions)
  s=0
  if n_elements(x) gt 0 then s+=1
  if n_elements(y) gt 0 then s+=1
  if n_elements(z) gt 0 then s+=1
  if n_elements(w) gt 0 then s+=1
  if(ndims gt 0) then begin
    result=make_array([size(x,/dimensions),s],type=size(x,/type));
  end else begin
    result=make_array(s,type=size(x,/type));
  end
  case ndims of
    0:  begin
          if s ge 1 then result[0]=x;
          if s ge 2 then result[1]=y;
          if s ge 3 then result[2]=z;
          if s ge 4 then result[3]=w;
        end
    1:  begin
          if s ge 1 then result[*,0]=x;
          if s ge 2 then result[*,1]=y;
          if s ge 3 then result[*,2]=z;
          if s ge 4 then result[*,3]=w;
        end
    2:  begin
          if s ge 1 then result[*,*,0]=x;
          if s ge 2 then result[*,*,1]=y;
          if s ge 3 then result[*,*,2]=z;
          if s ge 4 then result[*,*,3]=w;
        end
    else: begin
          print,"Unsupported grid dimension"
          return,-1
        end
  endcase
  return,result
end
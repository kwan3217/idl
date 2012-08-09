;shape_grid.pro - returns the shape and size of a grid of vectors.
;
;Inputs:
;  v - grid of vectors of form v[size_1,size_2,...,size_k,N]. N can be any positive
;      integer value, but usually is 3 for position vectors and 4 for
;      quaternions
;Returns:
;  A 1D array of integers [size_1,size_2,...,size_k]. This array is suitable
;  for creating scalar grids directly with dblarr(shape_grid(...)) or similar,
;  and suitable for creating vector or quaternion grids with dblarr([shape_grid(...),N])
function shape_grid,v
  ndims=size(v,/n_dimensions)-1
  return,(size(v,/dimensions))[0:ndims-1]
end

function calc_voronoi2,epoch
  ;Works on paper - hope there are no special cases
  return,[epoch[0],(epoch[0:n_elements(epoch)-3]+epoch[2:n_elements(epoch)-1])/2,!Values.d_infinity]
end
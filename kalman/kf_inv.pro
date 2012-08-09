;kf_inv - a version of invert() which doesn't crash when passed a scalar
function kf_inv,a
  if n_elements(a) eq 1 then return,1d/double(a)
  return,invert(a)
end


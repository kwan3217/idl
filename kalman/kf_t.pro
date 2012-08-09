;kf_t - a version of transpose() which doesn't crash when passed a scalar
function kf_t,a
  if n_elements(a) eq 1 then return,a
  return,transpose(a)
end


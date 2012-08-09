function quat_normalize,q
  norm_q=sqrt(total(q^2))
  return,q/norm_q
end

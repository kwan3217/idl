function quantile,data,q
  s=sort(data)
  return,data[s[q*n_elements(data)]]
end
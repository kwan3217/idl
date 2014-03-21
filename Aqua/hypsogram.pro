function hypsogram,d,locations=locations
  s=size(d,/dim)
  n_lat=s[1]
  lat=dindgen(n_lat)/n_lat*!dpi-!dpi/2
  c_lat=cos(lat)
  d_min=min(d)
  d_max=max(d)
  result=double(histogram(d,binsize=1,min=d_min,max=d_max,locations=locations)*0)
  for i=0,n_lat-1 do begin
    result+=double(histogram(d[*,i],binsize=1,min=d_min,max=d_max))*c_lat[i]
  end
  return,result
end
  
  
function bmw_CC,z
  result=double(z)
  w=where(z gt 0,count)
  if count gt 0 then result[w]=(1-cos(sqrt(z[w])))/z[w]
  w=where(z eq 0,count)
  if count gt 0 then result[w]=0.5d
  w=where(z lt 0,count)
  if count gt 0 then result[w]=(1-cosh(sqrt(-z[w])))/z[w]
  return,result
end



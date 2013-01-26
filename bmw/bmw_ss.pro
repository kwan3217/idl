function bmw_SS,z
  result=double(z)
  w=where(z gt 0,count)
  if count gt 0 then begin
    sz=sqrt(z[w])
    result[w]=(sz-sin(sz))/sz^3
  end
  w=where(z eq 0,count)
  if count gt 0 then result[w]=1d/6d
  w=where(z lt 0,count)
  if count gt 0 then result[w]=(1-cosh(sqrt(-z[w])))/z[w]
  return,result
end



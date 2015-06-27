function flare,a,b,t,ddt=ddt,normalize=normalize
  result=t*0d
  ddt=result
  w=where(t>0,count)
  if count gt 0 then begin
    e1=exp(-t[w]/a)
    e2=1-exp(-t[w]/b)
    result[w]=e1*e2
    ea=e1/a
    eb=e2
    ec=e1
    ed=-e2/b
    ddt[w]=ea*eb+ec*ed
  end
  m=max(result)
  if m gt 0 and keyword_set(normalize) then begin
    result/=m
    ddt/=m
  end
  return,result
end
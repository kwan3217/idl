function open_brackets,j,s
  if s[0] eq 0 then return,""
  ai=array_indices(s,j,/dim)
  result=""
  for i=0,n_elements(ai)-1 do begin
    if(ai[i]) ne 0 then return,result
    result="["+result
  end
  return,result
end

function close_brackets,j,s
  if s[0] eq 0 then return,""
  ai=array_indices(s,j,/dim)
  result=","
  for i=0,n_elements(ai)-1 do begin
    if(ai[i]) ne s[i]-1 then return,result
    result="]"+result
  end
  return,result
end

function array_to_code,a,indent=indent
  result=""
  s=size(a,/dim)
  for j=0,n_elements(a)-1 do begin
    result=result+open_brackets(j,s)
    case size(a,/type) of
      1: result+=string(format='(%"%dB")',a[j])
      2: result+=string(format='(%"%d")',a[j])
      3: result+=string(format='(%"%dL")',a[j])
      4: result+=string(format='(%"%14.7e")',a[j])
      5: result+=string(format='(%"%50.20fd")',a[j])
      7: result+=string(format='(%"''%s''")',a[j])
      8: result+=structure_to_code(a[j],indent=indent+2)
      12:result+=string(format='(%"%dU")',a[j])
      13:result+=string(format='(%"%dUL")',a[j])
      else: message,"Unhandled type "+string(size(a,/type))
    end
    result=result+close_brackets(j,s)
  end
  while strmid(result,strlen(result)-1,1) eq "," do result=strmid(result,0,strlen(result)-1)
  return,result
end

function structure_to_code,str,indent=indent
  if n_elements(indent) eq 0 then indent=0
  if indent gt 0 then tab1=string(bytarr(indent)+32b) else tab1=""
  tab2=string(bytarr(indent+2)+32b)
  t=tag_names(str)
  result=tab1+'{ $'+string(13b)
  for i=0,n_elements(t)-1 do begin
    result=result+tab2+t[i]+": "
    result=result+array_to_code(str.(i),indent=indent)
    if i lt n_elements(t)-1 then result+=","
    result+=" $"+string(13b)
  end
  result+=tab1+"}"
  return,result
end
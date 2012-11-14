function get_double,data,idx
  result=dblarr(n_elements(idx))
  if ~is_ieee_big() then begin
    for i=0,n_elements(idx)-1 do begin
      result[i]=double(reverse(data[idx[i]:idx[i]+7]),0)
    end
  end else begin
    for i=0,n_elements(idx)-1 do begin
      result[i]=double(data[idx[i]:idx[i]+7],0)
    end
  end
  if n_elements(result) eq 1 then result=result[0]
  return,result
end

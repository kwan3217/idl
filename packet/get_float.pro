function get_float,data,idx
  result=fltarr(n_elements(idx))
  if ~is_ieee_big() then begin
    for i=0,n_elements(idx)-1 do begin
      result[i]=float(reverse(data[idx[i]:idx[i]+3]),0)
    end
  end else begin
    for i=0,n_elements(idx)-1 do begin
      result[i]=float(data[idx[i]:idx[i]+3],0)
    end
  end
  if n_elements(result) eq 1 then result=result[0]
  return,result
end

function iuvs_header_evaluate,value_
  value=strtrim(value_,2)
  if strmid(value,0,2) eq '0x' then return,(tohex(strlowcase(strmid(value,2)),8))[0]
  if value eq 'TWELVE' then return,12
  if value eq 'SIXTEEN' then return,16
  if value eq 'Disabled' then return,0
  if value eq 'Enabled' then return,1
  if where(strmid(value,0,1) eq ['0','1','2','3','4','5','6','7','8','9','-']) ge 0 then return,(long(value))[0]
  return,value
end

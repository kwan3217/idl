function get_data,data,idx,type,shift,length,rep
  if n_elements(length) gt 0 && length lt 0 then begin
    l=n_elements(data)-idx
    if type eq 7 then ttype=1 else ttype=type
    result=swap_endian(/swap_if_little,fix(data,type=ttype,idx,l/type_length(type)))
    if(type eq 7) then result=string(result)
    return,result
  end else begin
    if ~keyword_set(rep) or n_elements(idx) ne 1 then rep=1
    if type eq 1 then begin
      if rep gt 1 then idx=idx+indgen(rep)*1
      return,get_u8(data,idx,shift,length)
    end else if type eq 7 then begin
      if rep gt 1 then idx=idx+indgen(rep)*1
      return,string(get_u8(data,idx,shift,length))
    end else if type eq 2 then begin
      if rep gt 1 then idx=idx+indgen(rep)*2
      return,get_i16(data,idx)
    end else if type eq 3 then begin
      if rep gt 1 then idx=idx+indgen(rep)*4
      return,get_i32(data,idx)
    end else if type eq 12 then begin
      if rep gt 1 then idx=idx+indgen(rep)*2
      return,get_u16(data,idx,shift,length)
    end else if type eq 13 then begin
      if rep gt 1 then idx=idx+indgen(rep)*4
      return,get_u32(data,idx)
    end else if type eq 4 then begin
      if rep gt 1 then idx=idx+indgen(rep)*4
      return,get_float(data,idx)
    end else if type eq 5 then begin
      if rep gt 1 then idx=idx+indgen(rep)*8
      return,get_double(data,idx)
    end else message,"Unknown Type "+string(type)
  end
end

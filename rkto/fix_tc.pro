function fix_tc,tc,sec=sec
  w=tc lt shift(tc,1)
  w[0]=0
  result=ulong64(total(w,/c))*3600000000ULL +tc
  if keyword_set(sec) or n_elements(sec) eq 0 then begin
    return,result/60d6
  end else begin
    return,result
  end
end

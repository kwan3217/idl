pro hex16_to_bin,infn,oufn
  openr,/get,inf,infn
  i=0
  hex=['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F']
  while ~eof(inf) do begin
    a=''
    readf,inf,a
    a=strupcase(strtrim(a,2))
    if strmid(a,0,1) ne '#' and strlen(a) ge 4 then begin
      out=0U
      for i=0,strlen(a)-1 do begin
        w=where(hex eq strmid(a,i,1),count)
        if count gt 0 then out=out*16+uint(w[0])
      end
      if n_elements(data) eq 0 then data=out else data=[data,out]
    end
  end
  free_lun,inf
  swap_endian_inplace,data,/swap_if_little
  openw,/get,ouf,oufn
  writeu,ouf,data  
  free_lun,ouf
end

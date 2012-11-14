function iuvs_parse_lin,filename
  openr,inf,filename,/get_lun
  ;size:    width of each nonlinear bin - command value is size-1, this is full size
  ;offset:  distance from edge to first bin
  ;length:  number of pixels in bins - command value is length-1, this is full length
  result=make_array(20,value={size:0u,offset:0u,length:0u})
  line = '' & READF, inf, line
  ; While there is text left, output it:
  while ~eof(inf) do begin
    line=strtrim(strlowcase(line))
    tok=stregex(line,/subexpr," *set +rsp +lin_bin_row +with +(.*$)",length=length)
    if tok[0] gt -1 then begin
      params=strmid(line,tok[1],length[1])
      tok=stregex(params,/subexpr,"row +([0-9]+)",length=length)
      if tok[0] gt -1 then begin
        row=fix(strmid(params,tok[1],length[1]))
        tok=stregex(params,/subexpr,"size +([0-9]+)",length=length)
        if tok[0] gt -1 then begin
          size=fix(strmid(params,tok[1],length[1]))
          tok=stregex(params,/subexpr,"offset +([0-9]+)",length=length)
          if tok[0] gt -1 then begin
            offset=fix(strmid(params,tok[1],length[1]))
            tok=stregex(params,/subexpr,"length +([0-9]+)",length=length)
            if tok[0] gt -1 then begin
              length=fix(strmid(params,tok[1],length[1]))
              result[row].size=size+1
              result[row].offset=offset
              result[row].length=length+1
            end
          end
        end
      end
    end
    readf, inf, line
  end

  ; Close the files and deallocate the units:
  free_lun, inf
  return,result
end

function iuvs_parse_prc,filename
  openr,inf,filename,/get_lun
  line = '' & READF, inf, line
  data=''
  ; While there is text left, output it:
  while ~eof(inf) do begin
    line=strtrim(strlowcase(line))
    tok=strsplit(line,/regex,' +',/extract)
    if n_elements(tok) ge 6 then if tok[0] eq 'stuff' and $
       tok[1] eq 'rsp' and   $
       tok[2] eq 'dword' and $
       tok[3] eq 'with' and  $
       tok[4] eq 'data' then begin
      data=data+strmid(tok[5],2)
    end
    readf, inf, line
  end

  ; Close the files and deallocate the units:
  free_lun, inf
  return,data
end

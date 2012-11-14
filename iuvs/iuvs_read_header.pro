function iuvs_read_header,fn
  openr,inf,'sci_header_'+fn+'.txt',/get_lun
  while ~eof(inf) do begin
    s=''
    readf,inf,s
    w=strpos(s,":")
    if w gt 0 then begin
      key=iuvs_header_fix_key(strmid(s,0,w))
      val=iuvs_header_evaluate(strmid(s,w+1))
      if n_elements(result) eq 0 then result=create_struct(key,val[0]) else result=create_struct(result,key,val[0])
    end
;    print,s
  end
  free_lun,inf
  if strpos(fn,'FUV') ge 0 then result=create_struct(result,'xuv','FUV') else result=create_struct(result,'xuv','MUV')
  result=create_struct(result,'timestamp',iuvs_timestamp(result.start_time,result.start_time__sub,result.cadence,result.image_number))
  result=create_struct(result,'mirror_this_dn',result.mirror_pos+(result.image_number+1)*result.step_size)
  a0=12939d
  a1=364.0889d
  result=create_struct(result,'mirror_this_deg',(double(result.mirror_this_dn-a0)/a1))
  result=create_struct(result,'fov_this_deg',2d*result.mirror_this_deg)
  return,result
end


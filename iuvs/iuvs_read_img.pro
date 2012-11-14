function iuvs_read_img,fn,header=header,a=a,lin=lin,non=non
  if n_elements(header) eq 0 then begin
    header=iuvs_read_header(fn)
    a=read_binary('sci_file_'+fn+'.dat',endian="big",data_type=size(0U,/type))
  end
  if n_elements(a) lt header.length then message,"Not enough pixels in the file"
  if n_elements(a) gt header.length then begin
    message,/info,string(format='(%"Too many pixels in file. Header says %d, file length is %d words")',header.length,n_elements(a))
    a=a[0:header.length-1]
  end
  iuvs_get_row,header,xw=xw,xt=xt,yw=yw,yt=yt,lin=lin,non=non
  if n_elements(a) ne total(xt)*total(yt) then message,string(format='(%"Wrong number of pixels in image. Expected %dx%d (%d), found %d in file, table row %d")',total(xt),total(yt),total(xt)*total(yt),n_elements(a),header.bin_x_row)
  b=reform(a,total(xt),total(yt))
  if header.data_compression then b=iuvs_uncompress(b)
  return,b
end
  

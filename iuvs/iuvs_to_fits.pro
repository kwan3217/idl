pro iuvs_to_fits,fn,img=img,header=header,mu=mu,sigma=sigma,verbose=verbose
  silent=~keyword_set(verbose)
  print,fn
  errno=0
  catch,errno
  if errno eq 0 then begin
    img=iuvs_read_img(fn,header=header,lin_table=lin_table,nonlin_table=nonlin_table)
  end else begin
    help,!error_state,/str
    message,/info,"Error reading raw data, FITS file not created"
    return
  end
  catch,/cancel
  if header.data_compression then img=iuvs_uncompress(img)
  keywords=iuvs_make_keyword(header)
  mwrfits,img,fn+'.fits',keywords,/create,silent=silent
  w=where(strtrim(keywords,2) eq 'END')
  keywords=keywords[0:w-1]
  set_plot,'z'
  device,set_resolution=[1024,512]
  erase
  loadct,39
  tvlct,r,g,b,/get
  tv,congrid(alog(img)*12d,512,512)
  for i=0,n_elements(keywords)-1 do begin
    xyouts,/dev,512,512-11*(i+1),keywords[i]
  end

  iuvs_get_row,header.bin_x_row,x_w=xw,x_t=xt,y_w=yw,y_t=yt

  xwt=xw[where(xt)]
  ywt=yw[where(yt)]

  binsize=transpose(ywt) ## xwt

  stat_img=double(img)/binsize

  mu=mean(stat_img)
  sigma=stdev(stat_img)
  i=n_elements(keywords)+1
  print,i
  xyouts,/dev,512,512-11*i,string(format='(%"Mean value: %f")',mu) 
  i++
  xyouts,/dev,512,512-11*i,string(format='(%"Stdev value: %f")',sigma) 

  pngimg=tvrd()
  write_png,fn+'.png',pngimg,r,g,b

  keyword=["EXTNAME = 'Metadata'","END"]
  mwrfits,header,fn+'.fits',keyword,silent=silent
  if header.bin_type eq 'NON LINEAR' then begin
    mwrfits,xw,fn+'.fits',["EXTNAME = 'XBinWidth'","END"],silent=silent
    mwrfits,xt,fn+'.fits',["EXTNAME = 'XBinTransmit'","END"],silent=silent
    mwrfits,yw,fn+'.fits',["EXTNAME = 'YBinWidth'","END"],silent=silent
    mwrfits,yt,fn+'.fits',["EXTNAME = 'YBinTransmit'","END"],silent=silent
;    keyword=["EXTNAME = 'Checkerboard'","END"]
;    iuvs_draw_bins,header.bin_x_row,img=checker
;    mwrfits,byte(checker),fn+'.fits',keyword,silent=silent
;    keyword=["EXTNAME = 'DebinnedImage'","END"]
;    mwrfits,uint(iuvs_bin(/inverse,row=header.bin_x_row,img)),fn+'.fits',keyword,silent=silent
  end
end


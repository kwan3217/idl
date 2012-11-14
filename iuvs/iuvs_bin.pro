;Bin an IUVS image. Given an image and either a binning table or table row number, calculate the binned image
;Input:
;  img:        The image to bin
;  xwidth=:    Array of widths of each bin in the X (spectral) direction. This should be the exact number of pixels
;              in the bin, no off-by-1 as is in the binning tables
;  xtransmit=: Array of 1 or 0. 1 means to transmit (include) its column in the returned image, 0 means skip
;  ywidth=:    Array of widths of each bin in the Y (spatial) direction. 
;  ytransmit=: Array of 1 or 0, transmit or not.
;  row=:       Row number from Dale's binning table. If set, xw=, xt=, yw=, and yt= will be overwritten with the
;              values from this row. See iuvs_get_row() for table details
;  /inverse:   if set, input is a binned image to be "unbinned". Output will be a full-size 1024x1024 image
;              with the DNs from each bin in the input spread over the correct pixels in the output. So a bin with 256 DNs
;              which is 4x4 will result in a 4x4 block of pixels, each with 16 DNs.
;  /bounds:    If set, output is limited to 0xFFFF in each pixel. If a bin should have more than that, it will roll over. For
;              instance, if a bin should be 70000, it will only be 4464. This is intended to match hardware behavior with
;              compression off. If not set, result will be limited to 0xFFFFFFFF, which can only overflow if every pixel
;              in the image is 0xFFF and every pixel is assigned to one bin
;  /compress:  If set, compress the data using the standard IUVS lossy compression method
;Return:
;  A 2D array representing the binned (or unbinned if /inverse) image. Spectral is the first index, is horizontal, 
;  low numbers on the left, high on the right. Spatial is the second index, is vertical, low numbers on the bottom, high on the top.
;  If /bounds (or /compressed)               
function iuvs_bin,img,xwidth=xw,xtransmit=xt,ywidth=yw,ytransmit=yt,row=row,inverse=inverse,bounds=bounds,compress=compress,_extra=extra
  if n_elements(row) ne 0 then begin
    iuvs_get_row,row,x_w=xw,y_w=yw,x_t=xt,y_t=yt,_extra=extra
  end
  if ~keyword_set(inverse) then begin
    result=ulonarr(total(xt),total(yt))
  end else begin
    result=dblarr(1024,1024)
  end
  xbin_stop=total(/c,xw)-1
  xbin_start=xbin_stop-xw+1

  ybin_stop=total(/c,yw)-1
  ybin_start=ybin_stop-yw+1
  
  w=where(xt)
  xbin_start=xbin_start[w]
  xbin_stop =xbin_stop [w]
  w=where(yt)
  ybin_start=ybin_start[w]
  ybin_stop =ybin_stop [w]
  for xi=0,n_elements(xbin_start)-1 do begin
    for yi=0,n_elements(ybin_start)-1 do begin
      if ~keyword_set(inverse) then begin
        result[xi,yi]=total(img[xbin_start[xi]:xbin_stop[xi],ybin_start[yi]:ybin_stop[yi]],/integer)
      end else begin
        result[xbin_start[xi]:xbin_stop[xi],ybin_start[yi]:ybin_stop[yi]]=double(img[xi,yi])/double((xbin_stop[xi]+1-xbin_start[xi])*(ybin_stop[yi]+1-ybin_start[yi]))
      end
    end
  end
  if keyword_set(compress) then begin
    result=iuvs_compress(result)
  end
  if keyword_set(bounds) then begin
    result=uint(result)
  end
  return,result
end


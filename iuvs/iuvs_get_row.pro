;Given a sci header row number, find the binning pattern that matches it.
;Input:
;  header.bin_x_row,header.bin_y_row  - values from image telemetry, used to index either linear, spectral, or spatial tables
;  nonlinear= - set to path to folder holding tables in PRC form named spat%02d.prc and spec%02d.prc, where %02d is placeholder for row number
;               If set, non-linear binning is used
;  linear=    - set to path to file containing linear table commands in PRC form
;               if set, linear binning is used 
;Output:
;  xw=       - width of X (spatial) bins in pixels
;  xt=       - for each X (spatial) bin, set to 1 if bin is present in image, 0 otherwise
;  yw=       - width of Y (spectral) bins in pixels
;  yt=       - for each Y (spectral) bin, set to 1 if bin is present in image, 0 otherwise
;SPATIAL  is X, displayed horizontally in IDL, low index at left
;SPECTRAL is Y, displayed vertically in IDL, low index at bottom
pro iuvs_get_row,header,xwidth=xw,xtransmit=xt,ywidth=yw,ytransmit=yt,nonlinear=prc,linear=lin,xs=xs,xo=xo,xl=xl,ys=ys,yo=yo,yl=yl
  r=routine_info('iuvs_get_row',/source)
  if n_elements(lin) eq 0 then lin=file_dirname(r.path)+'/app_cal_test.prc'
  if n_elements(prc) eq 0 then non=file_dirname(r.path)+'/nonlinear_tables/table1'
  common iuvs_get_row_static,spec_prc,spat_prc,spat,spec,lintable_prc,lintable
  if header.bin_type eq 'NON LINEAR' then begin
    ;Nonlinear binning
    if n_elements(spec_prc) eq 0 then begin
      spat_prc=strarr(20)
      spec_prc=strarr(20)
      spat=strarr(20)
      spec=strarr(20)
    end
    if prc ne spat_prc[header.bin_x_row] then begin
      spat_prc[header.bin_x_row]=prc
      spat[header.bin_x_row]=iuvs_parse_prc(string(format='(%"%s/spat%02d.prc")',prc,header.bin_x_row))
    end
    if prc ne spec_prc[header.bin_y_row] then begin
      spec_prc[header.bin_y_row]=prc
      spec[header.bin_y_row]=iuvs_parse_prc(string(format='(%"%s/spec%02d.prc")',prc,header.bin_y_row))
    end 
    translate_dale_email,spat[header.bin_x_row],bin_width=xw,bin_transmit=xt
    translate_dale_email,spec[header.bin_y_row],bin_width=yw,bin_transmit=yt
  end else begin
    ;Linear binning
    if n_elements(lintable_prc) eq 0 then begin
      lintable_prc=lin
      lintable=iuvs_parse_lin(lin)
    end
    ys=lintable[header.bin_x_row].size
    yl=lintable[header.bin_x_row].length
    yo=lintable[header.bin_x_row].offset
    yw=intarr(total(lintable[header.bin_x_row].length/lintable[header.bin_x_row].size))+lintable[header.bin_x_row].size
    yt=yw*0+1
    if lintable[header.bin_x_row].offset gt 0 then begin
      yt=[0,yt]
      yw=[lintable[header.bin_x_row].offset,yw]
    end
    xs=lintable[header.bin_y_row].size
    xl=lintable[header.bin_y_row].length
    xo=lintable[header.bin_y_row].offset
    xw=intarr(total(lintable[header.bin_y_row].length/lintable[header.bin_y_row].size))+lintable[header.bin_y_row].size
    xt=xw*0+1
    if lintable[header.bin_y_row].offset gt 0 then begin
      xt=[0,xt]
      xw=[lintable[header.bin_y_row].offset,xw]
    end
  end
end


pro iuvs_draw_bins,row,img=result,draw=draw
  if n_elements(row) ne 0 then begin
    iuvs_get_row,row,x_w=xw,y_w=yw,x_t=xt,y_t=yt,_extra=extra
  end
  print,total(xt),total(yt)
  result=ulonarr(1024,1024)
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
  acc=0
  for xi=0,n_elements(xbin_start)-1 do begin
    acc=xi mod 2
    for yi=0,n_elements(ybin_start)-1 do begin
      result[xbin_start[xi]:xbin_stop[xi],ybin_start[yi]:ybin_stop[yi]]=(acc mod 2)*127+127
      acc++
    end
  end
  result=uint(result)
  if keyword_set(draw) then tv,result
end

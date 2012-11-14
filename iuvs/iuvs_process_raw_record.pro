;Input: 
; f - filename of raw record file to process
; lin= - optional. If set, this is the path to a cstol script with linear 
;        binning commands, to be used to set up the linear binning table
; non= - optional. If set, path to a folder containing cstol scripts of 
;        the form [spat|spec]%02d.prc defining the nonlinear binning table
pro iuvs_process_raw_record,f,lin=lin,non=non
  if n_elements(path) gt 0 then cd,current=current,path
  openr,inf,f,/get_lun
  status=1
  while status do begin
    img=iuvs_extract_img(inf=inf,pkt=pkt,lin=lin,non=non,status=status)
    if status then if pkt.xuv eq "FUV" then begin
      if n_elements(totf) eq 0 then totf=total(double(img)) else totf=[totf,total(double(img))]
      if n_elements(headerf) eq 0 then headerf=pkt else headerf=[headerf,pkt]
    end else begin
      if n_elements(totm) eq 0 then totm=total(double(img)) else totm=[totm,total(double(img))]
      if n_elements(headerm) eq 0 then headerm=pkt else headerm=[headerm,pkt]
    end
  end
  close,inf
  free_lun,inf
  set_plot,'z'
  device,set_resolution=[960,540]
  loadct,39,rgb=rgb
  r=rgb[*,0]
  g=rgb[*,1]
  b=rgb[*,2]
  !p.multi=[0,2,1]
  sf=sort(headerf.timestamp)
  sm=sort(headerf.timestamp)
  cd,current=current
  path=file_basename(current)
  plot,headerf[sf].fov_this_deg,totf[sf],psym=-1,xtitle='FOV angle deg',ytitle='Total DN',title="FUV "+path,color=0,background=255,charsize=2,thick=2
  plot,headerm[sm].fov_this_deg,totm[sm],psym=-1,xtitle='FOV angle deg',ytitle='Total DN',title="MUV "+path,color=0,background=255,charsize=2,thick=2
  
;  tvscl,imgf
;  tvscl,imgm,950,0
;  surface,img[0],title=f[0],charsize=3
;  tvscl,img[0],0,0
;  surface,img[1],title=f[1],charsize=3
 ; tvscl,img[1],950,0
  graph=tvrd()
  write_png,'TotalVsFov.png',graph,r,g,b
;  write_png,'FuvMuvSurface.png',graph
  if n_elements(path) gt 0 then cd,current

end
pro iuvs_to_fits_1A,fn,img=img,header=header,verbose=verbose,desc=desc,version=ver,_extra=extra
  if n_elements(fn) gt 1 then begin
    heap_gc
    junk=temporary(this_img)
    iuvs_to_fits_1a,fn[0],img=this_img,header=this_header,mu=this_mu,sigma=this_sigma,verbose=verbose,desc=desc,version=ver,tot=this_tot,spotx=spotx,spoty=spoty,spotp=this_spot,max=this_img_max,_extra=extra
    img=ptr_new(this_img)
    header=this_header
    mu=this_mu
    tot=this_tot
    sigma=this_sigma
    spot=this_spot
    img_max=this_img_max
    for i=1,n_elements(fn)-1 do begin
      junk=temporary(this_img)
      iuvs_to_fits_1a,fn[i],img=this_img,header=this_header,mu=this_mu,sigma=this_sigma,verbose=verbose,desc=desc,version=ver,tot=this_tot,spotx=spotx,spoty=spoty,spotp=this_spot,max=this_img_max,_extra=extra
      this_img=[this_img,ptr_new(img)]
      header=[header,this_header]
      mu=[mu,this_mu]
      sigma=[sigma,this_sigma]
      tot=[tot,this_tot]
      spot=[spot,this_spot]
      img_max=[img_max,this_img_max]
    end
    return
  end
  if n_elements(desc) eq 0 then desc='desc'
  if n_elements(ver) eq 0 then ver=0
  silent=~keyword_set(verbose)
  if n_elements(img) eq 0 then begin
    print,fn
    errno=0
    catch,errno
    if errno eq 0 then begin
      img=iuvs_read_img(fn,header=header,_extra=extra)
    end else begin
      help,!error_state,/str
      message,/info,"Error reading raw data, FITS file not created"
      return
    end
    catch,/cancel
  end
  iuvs_get_row,header,xw=xw,xt=xt,yw=yw,yt=yt,xs=xs,xo=xo,xl=xl,ys=ys,yo=yo,yl=yl,_extra=extra
  keywords=iuvs_make_keyword(header,'1A')
  et_cap=header.timestamp
  cspice_et2utc,et_cap,"ISOD",5,utcstr
  yyyy=fix(strmid(utcstr,0,4))
  doy=fix(strmid(utcstr,5,3))
  hh=fix(strmid(utcstr,9,2))
  nn=fix(strmid(utcstr,12,2))
  ss=fix(strmid(utcstr,15,2))
  oufn=string(format='(%"MVN_IUV_L1A_%s-%04d%03d-%02d%02d%02d-%02d.fits")',header.xuv,yyyy,doy,hh,nn,ss,ver)
  mwrfits,img,oufn,keywords,/create,silent=silent
  w=where(strtrim(keywords,2) eq 'END')
  keywords=keywords[0:w-1]
  set_plot,'z'
  device,set_resolution=[1024,512]
  erase
  loadct,39,rgb=rgb,/silent
  r=rgb[*,0]
  g=rgb[*,1]
  b=rgb[*,2]
  tv,congrid(alog(img)*12d,512,512)
  for i=0,n_elements(keywords)-1 do begin
    xyouts,/dev,512,512-8*(i+1),keywords[i],charsize=0.8
  end

  pngimg=tvrd()
  pngfn=string(format='(%"%s_%04d_%04d_%09d.png")',header.xuv,header.obs_id,header.image_number,header.start_time)
  write_png,pngfn+'.png',pngimg,r,g,b

  keyword=["EXTNAME = 'Engineering'","END"]
  eng_skip=['NAME','VER','TYPE','SCND_HDR','APID','GRP_FLG','SSC','DATA_LEN','SC_CLK_COARSE','SC_CLK_FINE','DFB_TERTIARY']
  t=tag_names(header)
  for i=0,n_elements(t)-1 do begin
    junk=where(eng_skip eq t[i],count)
    if count eq 0 and n_elements(header.(i)) eq 1 then begin
      if n_elements(eng_header) eq 0 then eng_header=create_struct(t[i],header.(i)) else eng_header=create_struct(eng_header,t[i],header.(i)) 
    end
  end
  mwrfits,eng_header,oufn,keyword,silent=silent
  s=create_struct('XBinWidth',xw,'XBinTransmit',xt,'YBinWidth',yw,'YBinTransmit',yt)
  mwrfits,s,oufn,["EXTNAME = 'NonlinearBinning'","END"],silent=silent
  if header.bin_type eq 'NON LINEAR' then begin
    s=create_struct('XOffset',xo,'XSize',xs,'XLength',xl,'YOffset',yo,'YSize',ys,'YLength',yl)
    mwrfits,s,oufn,["EXTNAME = 'LinearBinning'","END"],silent=silent
  end
    s=create_struct('PIXEL_CORNER_RA',dblarr(5,n_elements(where(xt)))*!values.d_nan,$
                    'PIXEL_CORNER_DEC',dblarr(5,n_elements(where(xt)))*!values.d_nan,$
                    'PIXEL_CORNER_LAT',dblarr(5,n_elements(where(xt)))*!values.d_nan,$
                    'PIXEL_CORNER_LON',dblarr(5,n_elements(where(xt)))*!values.d_nan,$
                    'PIXEL_CORNER_MRH_ALT',dblarr(5,n_elements(where(xt)))*!values.d_nan,$
                    'PIXEL_CORNER_MRH_ALT_RATE',dblarr(5,n_elements(where(xt)))*!values.d_nan,$
                    'PIXEL_MRH_LAT',dblarr(n_elements(where(xt)))*!values.d_nan,$
                    'PIXEL_MRH_LON',dblarr(n_elements(where(xt)))*!values.d_nan,$
                    'PIXEL_INCIDENCE_ANGLE',dblarr(n_elements(where(xt)))*!values.d_nan,$
                    'PIXEL_EMISSION_ANGLE',dblarr(n_elements(where(xt)))*!values.d_nan,$
                    'PIXEL_PHASE_ANGLE',dblarr(n_elements(where(xt)))*!values.d_nan,$
                    'SUB_SPACECRAFT_LAT',!values.d_nan,$
                    'SUB_SPACECRAFT_LON',!values.d_nan,$
                    'SUB_SOLAR_LAT',!values.d_nan,$
                    'SUB_SOLAR_LON',!values.d_nan,$
                    'SPACECRAFT_ALT',!values.d_nan,$
                    'V_SPACECRAFT',dblarr(3)*!values.d_nan,$
                    'V_SPACECRAFT_RATE',dblarr(3)*!values.d_nan,$
                    'V_SUN',dblarr(3)*!values.d_nan,$
                    'V_SUN_RATE',dblarr(3)*!values.d_nan,$
                    'VX_SPACECRAFT',dblarr(3)*!values.d_nan,$
                    'VY_SPACECRAFT',dblarr(3)*!values.d_nan,$
                    'VZ_SPACECRAFT',dblarr(3)*!values.d_nan,$
                    'VX_INSTRUMENT',dblarr(3)*!values.d_nan,$
                    'VY_INSTRUMENT',dblarr(3)*!values.d_nan,$
                    'VZ_INSTRUMENT',dblarr(3)*!values.d_nan $
                    )
    mwrfits,s,oufn,["EXTNAME = 'Geometry'","END"],silent=silent
    s=create_struct('Ls',!radeg*cspice_lspcn("MARS",et_cap,"NONE"),$
                    'Cal_version',fix(0),$
                    'Obs_type','Lab cal',$
                    'Mission_phase','Prelaunch',$
                    'Target_name','Lab cal',$
                    'Orbit_Segment',fix(0),$
                    'Orbit_number',fix(0),$
                    'grating_select','unknown',$
                    'keyhole_select','unknown',$
                    'bin_pattern_index',0b,$
                    'wavelength',dblarr(n_elements(where(yt)),n_elements(where(xt)))*!values.d_nan,$
                    'wavelength_width',dblarr(n_elements(where(yt)))*!values.d_nan)
    mwrfits,s,oufn,["EXTNAME = 'Observation'","END"],silent=silent
;    keyword=["EXTNAME = 'Checkerboard'","END"]
;    iuvs_draw_bins,header.bin_x_row,img=checker
;    mwrfits,byte(checker),fn+'.fits',keyword,silent=silent
;    keyword=["EXTNAME = 'DebinnedImage'","END"]
;    mwrfits,uint(iuvs_bin(/inverse,row=header.bin_x_row,img)),fn+'.fits',keyword,silent=silent
end


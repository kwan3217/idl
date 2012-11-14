pro iuvs_process_fits,tag
  print,'fuv_stdev_'+tag+'.png'
  f=iuvs_get_files()
  for i=0,n_elements(f)-1 do begin
    iuvs_to_fits,f[i],/decompress,header=header,mu=this_mu,sigma=this_sigma
    if header.xuv eq 'FUV' then begin
      if n_elements(fuv_mu) eq 0 then fuv_mu=this_mu else fuv_mu=[fuv_mu,this_mu]
      if n_elements(fuv_sigma) eq 0 then fuv_sigma=this_sigma else fuv_sigma=[fuv_sigma,this_sigma]
      if n_elements(fuv_ts) eq 0 then fuv_ts=header.timestamp else fuv_ts=[fuv_ts,header.timestamp]
    end else begin
      if n_elements(muv_mu) eq 0    then muv_mu=this_mu          else muv_mu=   [muv_mu,this_mu]
      if n_elements(muv_sigma) eq 0 then muv_sigma=this_sigma    else muv_sigma=[muv_sigma,this_sigma]
      if n_elements(muv_ts) eq 0    then muv_ts=header.timestamp else muv_ts=   [muv_ts,header.timestamp]
    end
  end
  set_plot,'z'
  device,set_resolution=[640,480]
  erase
  loadct,39
  tvlct,r,g,b,/get
  yr=[min([fuv_sigma,muv_sigma]),max([fuv_sigma,muv_sigma])]
  plot,xtitle='Seconds from first FUV image',ytitle='Standard deviation (DN)',title='FUV standard deviation '+tag,fuv_ts-fuv_ts[0],fuv_sigma,psym=3,yr=yr
  pngimg=tvrd()
  write_png,'fuv_stdev_'+tag+'.png',pngimg,r,g,b
  plot,xtitle='Seconds from first MUV image',ytitle='Standard deviation (DN)',title='MUV standard deviation '+tag,muv_ts-muv_ts[0],muv_sigma,psym=3,yr=yr
  pngimg=tvrd()
  write_png,'muv_stdev_'+tag+'.png',pngimg,r,g,b
end

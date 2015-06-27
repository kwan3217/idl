pro gpx,oufn,ret,t,et0
  openw,ouf,oufn,/get
  printf,ouf,'<?xml version="1.0"?>'
  printf,ouf,'<gpx version="1.1" creator="target_mars.pro">'
  printf,ouf,'<trk>'
  printf,ouf,'<trkseg>'
  for i=0,n_elements(t)-1 do begin
    printf,ouf,'<trkpt lat="'+string(ret[i].llr[0]*180d/!dpi)+'" lon="'+string(ret[i].llr[1]*180d/!dpi)+'">'
    printf,ouf,'<ele>'+string(ret[i].alt)+'</ele>'
    et=t[i]+et0
    cspice_et2utc,et,"ISOC",3,cal
    printf,ouf,"<time>"+strmid(cal,0,23)+"</time>"
    printf,ouf,'</trkpt>'
  end  
  printf,ouf,'</trkseg>'
  printf,ouf,'</trk>'
  printf,ouf,'</gpx>'

  free_lun,ouf
end
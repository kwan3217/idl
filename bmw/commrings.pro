function dms,d,m,s
  result=(abs(double(d))+double(m)/60d +double(s)/3600d)
  if d<0 then result=-result
  return,result
end

;input 
;  lat0 -   latitude of starting point in radians
;  lon0 -   longitude of starting point in radians
;  range -  range angle from starting point in radians
;  radius - bearing in radians east of true north
pro gc_project,lat0,lon0,range,bearing,lat=lat,lon=lon
  r1=[cos(lon0)*cos(lat0),sin(lon0)*cos(lat0),sin(lat0)]
  e1=normalize_grid(crossp([0d,0,1],r1))
  n1=normalize_grid(crossp(r1,e1))
  MT=transpose([[n1],[r1],[e1]])
  lat=bearing
  lon=bearing
  r2r=compose_grid(cos(bearing)*sin(range),cos(range),sin(bearing)*sin(range))
  r2=MT##r2r
  resolve_grid,r2,x=x2,y=y2,z=z2
  lat=asin(z2)
  lon=atan(y2,x2)
end

pro gc_circle,radius,lat0,lon0,lat=lat,lon=lon
  gc_project,lat0,lon0,radius,reverse([dindgen(628),0d])/100d,lat=lat,lon=lon
end

function kmlcircle,radius,lat,lon,name,color
  crlf=string([13b,10b])
  result ="<Placemark>" +crlf
  result+="<name>"+name+"</name>"+crlf
  result+="<Polygon>"+crlf
  result+="<altitudeMode>clampToGround</altitudeMode>"+crlf
  result+=" <outerBoundaryIs>  <LinearRing>"  +crlf
  result+="<coordinates>"+crlf
  gc_circle,radius,lat,lon,lat=latq,lon=lonq
  for i=0,n_elements(latq)-1 do begin
    result+=strtrim(string(lonq[i]*!radeg),2)+','+strtrim(string(latq[i]*!radeg),2)+crlf
  end
  result+="  </coordinates>"+crlf
  result+="   </LinearRing> </outerBoundaryIs> </Polygon>"+crlf
  result+="   <Style> "+crlf
  result+="    <PolyStyle>  "+crlf
  result+="     <color>#00000000</color>"+crlf
  if n_elements(color) gt 0 then begin
    result+="     <color>#ff"+color+"</color>"+crlf
  end else begin
    result+="     <color>#ffffffff</color>"+crlf
  end
  result+="    <fill>0</fill>"+crlf
  result+="    <outline>1</outline>"+crlf
  result+="    </PolyStyle>" +crlf
  result+="    <LineStyle>" +crlf
  if n_elements(color) gt 0 then begin
    result+="     <color>#ff"+color+"</color>"+crlf
  end else begin
    result+="     <color>#ffffffff</color>"+crlf
  end
  result+="      <colorMode>normal</colorMode>      <!-- colorModeEnum: normal or random -->" +crlf
  result+="      <width>1</width>                            <!-- float -->" +crlf
  result+="    </LineStyle>" +crlf
  result+="   </Style>"+crlf
  result+="  </Placemark>"
  return,result
end

function kmlplacemark,lat,lon,name
  crlf=string([13b,10b])
  result ="  <Placemark>"+crlf
  result+="    <name>"+name+"</name>"+crlf
  result+="    <Point>"+crlf
  result+="      <coordinates>"+strtrim(string(lon*!radeg),2)+","+strtrim(string(lat*!radeg),2)+"</coordinates>"+crlf
  result+="    </Point>"+crlf
  result+="  </Placemark>"
  return,result
end

pro commrings

  re=6378d; Radius of Earth in km
  ro=re+650d; Radius of satellite orbit
  
  GSMask=5*!dtor; draw a ring around each DSN station where spacecraft is at this elevation
  GSName=['DSN Madrid', 'DSN Goldstone', 'DSN Canberra','Svalbard']
  GSLat=[ dms( 40,25,53), dms( 35,25,36),-dms( 35,24,05),78.217]*!dpi/180d
  GSLon=[-dms(  4,14,53),-dms(116,53,24), dms(148,58,54),12.975]*!dpi/180d
;  DSNLat=[40.431389,35.426667,-35.401389]*!dtor
;  DSNLon=[-4.248056,-116.89,148.981667]*!dtor
  
  DBRingBeta=[38,65.16]*!dtor
  DBRingLevel=[-2,-4]
  DBRingColor=['ff0000','00ff00']
;  DBRingLat=78.229772*!dtor
;  DBRingLon=15.407786*!dtor
  
  ;horizon depression
  alpha=!pi/2.0
  beta=asin(re*sin(alpha)/ro)
  print,"Horizon depression from orbit: ",beta*!radeg

  ;DNS mask
  ;Law of sines - alpha is angle at DSN, 90deg+DSN mask, beta is angle at sat
  ;               theta is angle at geocenter (needed)
  ;               sin(alpha)/Ro=sin(beta)/re
  ;               re*sin(alpha)/ro=sin(beta) beta is <90deg
  alpha=gsmask+!pi/2.0
  beta=asin(re*sin(alpha)/ro)
  ;triangle angles add to 180deg
  gsrad=!pi-alpha-beta
  crlf=string([13b,10b])
  result='<?xml version="1.0" encoding="UTF-8"?>'+crlf
  result+='<kml xmlns="http://www.opengis.net/kml/2.2">'
  result+='<Document>'
  for i=0,n_elements(gslat)-1 do begin
    if i gt 2 then result+=kmlcircle(gsrad,gslat[i],gslon[i],gsName[i])+crlf
    result+=kmlplacemark(gslat[i],gslon[i],gsName[i])+crlf
  end
  
  ;Find point on 5deg ring for Svalbard which is closest to Madrid
  ;Bearing (az) and range (sv_dsn_range) from Svalbard to Madrid
  sv_dsn_range=ell_dist(gslat[3],gslon[3],gslat[0],gslon[0],ell_az=az,/rad,a=re,b=re)/re
  print,'Range from Svalbard to Madrid: ',sv_dsn_range*re,'km'
  
  ;project from Svalbard out to 5deg ring along line from Svalbard to Madrid
  gc_project,gslat[3],gslon[3],gsrad,az,lat=lat_close,lon=lon_close
  result+=kmlplacemark(lat_close,lon_close,'Svalbard 5deg closest to Madrid - '+string(fix(re*(sv_dsn_range-gsrad)))+'km along ground')
  print,'Range from close point to Madrid: ',(sv_dsn_range-gsrad)*re,'km'
  
  rsc=[cos(lon_close)*cos(lat_close),sin(lon_close)*cos(lat_close),sin(lat_close)]*ro
  rm= [cos(gslon[0]) *cos(gslat[0]) ,sin(gslon[0]) *cos(gslat[0]) ,sin(gslat[0])]*re
  sr=sqrt(total((rsc-rm)^2))
  result+=kmlplacemark(lat_close,lon_close,'Svalbard 5deg closest to Madrid - '+string(fix(sr))+'km slant range')
  print,'Slant range from s/c over close point to Madrid: ',sr,'km'
  
  ;Radiated power rings - antenna points at nadir, power level known at certain angles 
  ;from antenna boresight
  ;law of sines
  result+=kmlcircle(0.01,gslat[3],gslon[3],'Svalbard area')+crlf
  for i=0,n_elements(dbringbeta)-1 do begin
    alpha=!pi-asin(ro*sin(dbringbeta[i])/re)
    powerrad=!pi-alpha-dbringbeta[i]
    result+=kmlcircle(powerrad,gslat[3],gslon[3],'Power '+string(DBRingLevel[i])+'dB',dbRingColor[i])+crlf
    ;project from Svalbard out to power ring along line from Svalbard to Madrid
    gc_project,gslat[3],gslon[3],powerrad,az,lat=lat_close,lon=lon_close
    result+=kmlplacemark(lat_close,lon_close,'Power '+string(DBRingLevel[i])+'dB')
  end
  
  result+='</Document></kml>'+crlf
  openw,ouf,'c:\users\jeppesen\Desktop\circle.kml',/get
  printf,ouf,result
  close,ouf
  free_lun,ouf
end

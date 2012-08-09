;Calculate aeroid radius
;Input
;  lat,lon - Aerocentric latitude and longitude
;return
;  aeroid radius in m
function marsaeroid,aclat,lon_
  common marsaeroid_static,aeroid,lat_aeroid,lon_aeroid
  if n_elements(aeroid) eq 0 then begin
    t_aeroid=create_struct('VERSION'         , 1.0, $
                           'TEMPLATENAME'    ,  '', $
                           'ENDIAN'          ,'big', $
                           'FIELDCOUNT'      ,1, $
                           'TYPECODES'       ,2, $
                           'NAMES'           ,'_', $
                           'OFFSETS'         ,'>0', $
                           'NUMDIMS'         ,2, $
                           'DIMENSIONS'      ,transpose(['5760','2880','','','','','','']), $
                           'REVERSEFLAGS'    ,transpose([0,1,0,0,0,0,0,0]), $
                           'ABSOLUTEFLAGS'   ,0, $
                           'RETURNFLAGS'     ,[1], $
                           'VERIFYFLAGS'     ,[0], $
                           'DIMALLOWFORMULAS',  1, $
                           'OFFSETALLOWFORMULAS',   1, $
                           'VERIFYVALS',    '')
    aeroid=read_binary('../icy/data/generic_tables/mega90n000eb.img',template=t_aeroid)
    cd,current
    aeroid=3396000d +double(aeroid._)

    lat_aeroid=dindgen(2880)/2880d*180d +90d/2880d -90d
    lon_aeroid=dindgen(5760)/5760d*180d +90d/2880d
  end
  lon=lon_
  w=where(lon lt 0,count)
  if count gt 0 then lon[w]+=!dpi*2
  return,interpolate(aeroid,linterp(0d,0d,!dpi*2d,5760d,lon),linterp(-!dpi/2d,0d,!dpi/2d,2880d,aclat))
end
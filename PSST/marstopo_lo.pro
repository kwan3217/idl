;Calculate aeroid radius
;Input
;  lat,lon - Aerocentric latitude and longitude
;return
;  Difference between planet radius and aeroid radius in m (topography above aeroid)
function marstopo_lo,aclat,lon_
  common marstopo_lo_static,topo,lat_topo,lon_topo
  if n_elements(topo) eq 0 then begin
    t_topo=create_struct('VERSION'         , 1.0, $
                           'TEMPLATENAME'    ,  '', $
                           'ENDIAN'          ,'big', $
                           'FIELDCOUNT'      ,1, $
                           'TYPECODES'       ,2, $
                           'NAMES'           ,'_', $
                           'OFFSETS'         ,'>0', $
                           'NUMDIMS'         ,2, $
                           'DIMENSIONS'      ,transpose(['11520','5760','','','','','','']), $
                           'REVERSEFLAGS'    ,transpose([0,1,0,0,0,0,0,0]), $
                           'ABSOLUTEFLAGS'   ,0, $
                           'RETURNFLAGS'     ,[1], $
                           'VERIFYFLAGS'     ,[0], $
                           'DIMALLOWFORMULAS',  1, $
                           'OFFSETALLOWFORMULAS',   1, $
                           'VERIFYVALS',    '')
    cd,'../..',current=current                           
    topo=read_binary('Data/Planet/Mars/Topography/megt90n000fb.img',template=t_topo)
    cd,current
    
    topo=double(topo._)
    lat_topo=dindgen(5760)/5760d*180d +90d/5760d -90d
    lon_topo=dindgen(11520)/11520d*180d +90d/5760d
  end
  return,interpolate(topo,linterp(0d,0d,!dpi*2d,11520d,lon_),linterp(-!dpi/2d,0d,!dpi/2d,5760d,aclat))
end
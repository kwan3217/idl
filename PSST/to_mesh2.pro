pro to_mesh2,llr,ouf
  xyz=llr_to_xyz(llr)
  resolve_grid,xyz,x=x,y=y,z=z
  printf,ouf,format='(%"  vertex_vectors {%d,")',n_elements(x)
  for i=0,n_elements(x)-1 do begin
    if i eq n_elements(x)-1 then comma="" else comma=","
    printf,ouf,format='(%"    <%15.7e,%15.7e,%15.7e>%s")',x[i],y[i],z[i],comma
  end
  printf,ouf,"  }"
end

function load_mola128,file_lat,file_lon
  bintemplate={ $
    VERSION: 1.0000000e+000, $
    TEMPLATENAME: 'topo', $
    ENDIAN: 'big', $
    FIELDCOUNT: 1L, $
    TYPECODES: 2, $
    NAMES: 'topo', $
    OFFSETS: '0', $
    NUMDIMS: 2L, $
    DIMENSIONS: [['11520'],['5632'],[''],[''],[''],[''],[''],['']], $
    REVERSEFLAGS: [[0B],[1B],[0B],[0B],[0B],[0B],[0B],[0B]], $
    ABSOLUTEFLAGS: 1B, $
    RETURNFLAGS: [1], $
    VERIFYFLAGS: [0], $
    DIMALLOWFORMULAS: 1, $
    OFFSETALLOWFORMULAS: 1, $
    VERIFYVALS: '' $
  }
  if file_lat ge 0 then ns="n" else ns="s"
  infn=string(format='(%"../icy/data/generic_tables/mars/radius/megr%02d%s%03dhb.img")',abs(file_lat),ns,file_lon)
  return,(read_binary(infn,template=bintemplate)).topo
end

function subset_mola128,file_lat,file_lon,start_lat,start_lon,end_lat,end_lon
  mola=load_mola128(file_lat,file_lon)
  i_bound=interpol([0d,11520],double(file_lon)+[0d,90],double([start_lon,end_lon]))
  j_bound=interpol([0d,5632],double(file_lat)+[-44d,0],double([start_lat,end_lat]))
  r=double(mola[min(i_bound):max(i_bound),min(j_bound):max(j_bound)])
  lat=(dindgen(1+(128*abs(start_lat-end_lat)))/128d +min([start_lat,end_lat]))*!dtor
  lat=rebin(transpose(lat),size(r,/dim))
  
  lon=(dindgen(1+(128*abs(start_lon-end_lon)))/128d +min([start_lon,end_lon]))*!dtor
  lon=rebin(lon,size(r,/dim))
  return,compose_grid(lat,lon,r+3396000d)
end
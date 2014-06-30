function msl_edl_v01_bsp_et
  in=read_binary('c:\jeppesen\workspace\Data\msl_edl_v01_bsp.dat',data_type=size(4d,/type),endian='big')
  in=reform(in,7,n_elements(in)/7)
  return,in
end
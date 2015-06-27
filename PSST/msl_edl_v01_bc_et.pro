function msl_edl_v01_bc_et
  in=read_binary('c:\jeppesen\workspace\Data\msl_edl_v01_bc.dat',data_type=size(4d,/type),endian='big')
  in=reform(in,5,n_elements(in)/5)
  return,in
end
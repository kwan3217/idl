pro iuvs_check_test_pat
  f=iuvs_get_files()
  for i=0,n_elements(f)-1 do begin
    junk=temporary(header) & junk=0
    hardware=iuvs_read_img(f[i],h=header)
    local=iuvs_test_pattern(he=header,hardware=hardware)
    tvscl,hardware-local
    w=where(hardware-local ne 0,count)
    print,f[i],count
  end
end
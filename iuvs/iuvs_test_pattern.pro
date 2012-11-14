function iuvs_test_pattern,obs=obs,muv=muv,fuv=fuv,bits=bits,header=header
  if n_elements(header) ne 0 then begin
    muv=header.xuv eq 'MUV'
    fuv=header.xuv eq 'FUV'
    bits=header.test_pattern
    obs=header.image_number
  end
  if n_elements(obs) eq 0 then obs=0
  if n_elements(bits) eq 0 then bits=12
  if keyword_set(fuv) then begin
    img=uindgen(1024L*1024L)+uint(obs)
  end else if keyword_set(muv) then begin
    img=reverse(uindgen(1024L*1024L))-uint(obs)
  end
  if bits lt 16 then img=img mod (2L^bits)
  img=reform(img,1024,1024)
  return,img
end


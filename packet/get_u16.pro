;Read a 16-bit unsigned integer from a BIG-ENDIAN byte stream
;  Input
;    data   - array of bytes containing big-endian data
;    idx    - scalar or array of indices to pull uints from
;    shift  - number of bits to shift RIGHT to align the LSB of the value. Optional
;    length - number of least significant bits to keep. Optional
;  Ouput
;    16-bit unsigned integer(s) either scalar or array of same size as idx
;Note:
;  This code depends on the byte array holding big-endian encoded data, but
;  does not depend on the endian-ness of the machine running this code.
function get_u16,data,idx,shift,length
  result=UINT(data[idx+0]*2^8)+UINT(data[idx+1])
  if n_elements(shift) gt 0 then begin
    result/=2^shift
  end
  if n_elements(length) gt 0 then begin
    result=result and (2^length-1)
  end
  return,result
end

;Read a 16-bit signed integer from a BIG-ENDIAN byte stream
;  Input
;    data - array of bytes containing big-endian data
;    idx  - scalar or array of indices of first byte(s) to pull i16(s) from
;  Ouput 
;    16-bit signed integer(s) either scalar or array of same size as idx
;Note:
;  This code depends on the byte array holding big-endian encoded data, but
;  does not depend on the endian-ness of the machine running this code.
function get_i16,data,idx
  result=uint(data[idx+0])*2U^ 8+uint(data[idx+1])*2U^ 0
  return,fix(result)
end

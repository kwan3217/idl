;Read a 32-bit unsigned integer from a BIG-ENDIAN byte stream
;  Input
;    data - array of bytes containing big-endian data
;    idx  - scalar or array of indices of first byte(s) to pull u32(s) from
;  Ouput 
;    32-bit unsigned integer(s) either scalar or array of same size as idx
;Note:
;  This code depends on the byte array holding big-endian encoded data, but
;  does not depend on the endian-ness of the machine running this code.
function get_u32,data,idx
  result=UINT(data[idx+0])*2UL^24+UINT(data[idx+1])*2UL^16+ $
         UINT(data[idx+2])*2UL^ 8+UINT(data[idx+3])*2UL^ 0
  return,result
end

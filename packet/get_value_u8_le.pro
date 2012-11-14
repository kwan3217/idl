;Mid level compression function - given a value and the number of bits in the value, put it in
;the compression buffer
;
;in/out
;  data - input: a compression buffer, an array of bytes
;         output: The buffer has the given value written to it. If the buffer is too short,
;           it is extended to whatever length is needed
;  ptr -  input: pointer to bit slot where least significant bit of value should be read from
;         output: pointer is pointed to bit slot after this value, where the LSB of the next
;           value should come from
;  len   - number of bits of value to read
;return
;  value read from compression buffer. Returned as a 16-bit (if len le 16) or 32-bit (if len gt 16)
;    two's complement signed intger. Buffer is interpreted as having a two's complement signed 
;    intger with the specified bit length at the specified spot, result is sign-extended to return
;    a 16-bit or 32-bit representation of the same value. 
;
;Example
;  if n_elements(buf) gt 0 then junk=temporary(buf) ;undefine buf if previously defined
;  if n_elements(ptr) gt 0 then junk=temporary(ptr) ;undefine ptr if previously defined
;  append_value_u8_le,buf,ptr, 4,4 ; append 14 to the buffer in 4 bits
;  append_value_u8_le,buf,ptr,-2,6 ; Append -2 to the buffer in 6 bits
;  ptr=0
;  print,get_value_u8_le(buf,ptr,4); Recover the first value from the buffer
;    4
;  print,get_value_u8_le(buf,ptr,6); Recover the next value from the buffer
;   -2
function get_value_u8_le,data,ptr,len,unsigned=unsigned,bit_be=bit_be,value_be=value_be
  if len gt 16 then begin
    max_len=32
    value=0L 
  end else begin
    max_len=16
    value=0
  end
  sign_bit=0
  for i=0,len-1 do begin
    bit=get_bit_u8_le(data,ptr,be=bit_be)
    if i eq 0 or ~keyword_set(value_be) then sign_bit=bit
    if keyword_set(value_be) then begin
      value=value or ishft(long(bit),len-i-1)
    end else begin
      value=value or ishft(long(bit),i)
    end
  end
  ;Sign extend if needed. If last (MSB) bit is set, then set all the rest of the bits.
  if len ne 16 and ~keyword_set(unsigned) and sign_bit then begin 
    for i=len,max_len-1 do value=value or ishft(1L,i)
  end
  if max_len eq 16 then value=fix(value)
  return,value
end
;Given a string with hex digits, return an array of numbers represented by the digits
;Input:
;  s - string to convert, may have spaces, digits, and lowercase a-f ONLY! anything else
;      will throw a message
;  digits: Number of hex digits to assign to each number. For instance, 2 will use every
;          two hex digits and form values ranging from 0-255. In general n will use n digits
;          to generate the numbers 0-(2^(4*n)-1)
;Return:
;  An array of signed long (32-bit) integers corresponding to the hex string passed in
;Notes: Numbers are created and assigned to the result from left to right. In other words,
;       toHex('12 34 56',2)=['12'xl,'34'xl,'56'xl]=[18L,52L,86L]
;       Individual numbers are interpreted in a big-endian form. So,
;       toHex('1234 5678',4)=['1234'xl,'5678'xl]=[4660L,22136L]
;       Spaces are skipped and insignificant, so 
;       toHex('12345678',4)=toHex('1234 5678',4)=toHex('12 34 56 78',4)
;                          =toHex('1 23 456 78',4)=[4660,22136]
function toHex,s,digits
  j=0
  b=0L
  hex=['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f']
  for i=0,strlen(s)-1 do begin
    if strmid(s,i,1) ne ' ' then begin
      b=b*16+where(strmid(s,i,1) eq hex,count)
      if count eq 0 then message,string(count)
      j=j+1
      if j eq digits then begin
        if n_elements(result) eq 0 then result=b else result=[result,b]
        b=0
        j=0
      end
    end
  end
  if j ne 0 then if n_elements(result) eq 0 then result=b else result=[result,b]
  return,result
end
  

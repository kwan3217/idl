function iuvs_compress,uncomp_,inverse=inverse
  if keyword_set(inverse) then return,iuvs_uncompress(uncomp_)
  
  if n_elements(uncomp_) gt 1 then begin
    result=uint(uncomp_)*0;
    for i=0,n_elements(result)-1 do result[i]=iuvs_compress(uncomp_[i])
    return,result
  end
  uncomp=ulong(uncomp_);
  if uncomp lt 8192 then return,uncomp
  expo=0
  while expo lt 15 and ((uncomp and 2UL^25UL) eq 0) do begin
    uncomp=uncomp*2UL
    expo=expo+1
  end 
  expo=(not expo) and 15
  mant=ishft(uncomp and (2UL^25UL-1),-13)
  result= ishft(uint(expo),12) or mant
  return,result
end

;Given some compressed data, calculate the uncompressed corresponding data
function iuvs_uncompress,comp,inverse=inverse
  if keyword_set(inverse) then return,iuvs_compress(comp)
  result=ulong(comp*0);
  expo=fix(ishft(comp and 'f000'xu,-12))-2;
  mant=(comp and '0fff'xu)+'1000'xu;
  c=where(expo ge 1,count,comp=nc,nc=ncount);
  if ncount gt 0 then result[nc]=comp[nc];
  if count gt 0 then result[c]=ishft(ulong(mant[c]),expo[c]);
  return,result
end

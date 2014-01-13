;this is a standard function in FORTRAN to return a number with the same
;magnitude as a, with the sign of b.
function dsign,a,b
  result=abs(a);
  Cond1=(b lt 0)
  Where1=where(Cond1,Count)
  if(Count ne 0) then begin
    result[Where1]*=-1;
  end
  return,result
end
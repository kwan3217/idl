function blackbrant_drymass,t
  m=t
  m[*]=443.89                   ;payload mass
  w=where(t lt 90,count)
  if count gt 0 then m[w]+=273.784 ;black brant shell mass
  w=where(t lt 6.2,count)
  if count gt 0 then m[w]+=320.504  ;terrier shell mass
  return,m
end


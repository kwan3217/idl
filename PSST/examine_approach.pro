pro examine_approach
  at={VERSION:1.00000, $
      DATASTART:0L, $
      DELIMITER:44b, $
      MISSINGVALUE:!values.f_NaN, $
      COMMENTSYMBOL:'', $
      FIELDCOUNT:9L, $
      FIELDTYPES:[5L,5,5,5,5,5,5,5,0],$
      FIELDNAMES:['jde','et','x','y','z','vx','vy','vz','FIELD9'],$
      FIELDLOCATIONS:[0L,17,38,59,80,102,124,146,167],$
      FIELDGROUPS:lindgen(9) $
      }
  b=read_ascii('c:\users\jeppesen\desktop\MSL Approach2.csv',template=at)
  etb=b.et
  x=b.x
  y=b.y
  z=b.z
  r=[[x],[y],[z]]
  vx=b.vx
  vy=b.vy
  vz=b.vz
  v=[[vx],[vy],[vz]]
  
  w=where(finite(etb))
  etb=etb[w]
  r=r[w,*]
  v=v[w,*]
  eo=elorb(r,v,3396.2,42828.375214)
  stop

  b=read_ascii('c:\users\jeppesen\desktop\MSL Depart.csv',template=at)
  etb=b.et
  x=b.x
  y=b.y
  z=b.z
  r=[[x],[y],[z]]
  vx=b.vx
  vy=b.vy
  vz=b.vz
  v=[[vx],[vy],[vz]]
  
  w=where(finite(etb))
  etb=etb[w]
  r=r[w,*]
  v=v[w,*]
  eo=elorb(r,v,6378.137,398600.4415)
  stop
end
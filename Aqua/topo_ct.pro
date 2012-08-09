pro topo_ct,sl,yellow,brown,r=r,g=g,b=b
  r=dblarr(256)
  g=r
  b=r
  t=indgen(256)
  if(sl eq 0) then begin
    b[0]=1
  end else begin
    b[0:sl]=linterp(0,0.5,sl,1,t[0:sl])
    r[sl/2:sl]=linterp(sl/2,0,sl,0.75,t[sl/2:sl])
    g[sl/2:sl]=linterp(sl/2,0,sl,0.75,t[sl/2:sl])
  end
  g[sl+1:(sl+yellow)/2]=linterp(sl+1,0.5,(sl+yellow)/2,1,t[sl+1:(sl+yellow)/2])
  g[(sl+yellow)/2:yellow]=1
  r[(sl+yellow)/2:yellow]=linterp((sl+yellow)/2,0,yellow,1,t[(sl+yellow)/2:yellow])
  g[yellow:brown]=linterp(yellow,1,brown,0.25,t[yellow:brown])
  r[yellow:brown]=linterp(yellow,1,brown,0.5,t[yellow:brown])
  r[brown:255]=linterp(brown,0.5,255,1,t[brown:255])
  g[brown:255]=linterp(brown,0.25,255,1,t[brown:255])
  b[brown:255]=linterp(brown,0,255,1,t[brown:255])
  tvlct,r*255,g*255,b*255
  tvscl,rebin(t,512,20)
  
end
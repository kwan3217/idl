pro Mars_close_approach
  start_cal='2014-Oct-19 19:00'
  stop_cal='2014-Oct-19 20:00'
  cspice_str2et,start_cal,start_et
  cspice_str2et,stop_cal,stop_et
  state=dblarr(ulong(stop_et-start_et)+1,6)
  for i=0ul,ulong(stop_et-start_et) do begin
    cspice_spkezr,'1003228',i+start_et,'ECLIPJ2000','NONE','499',starg,ltime
    state[i,*]=starg
  end
  r=sqrt(total(state[*,0:2]^2,2))
  mindist=min(r,minidx)
  v=sqrt(total(state[*,3:5]^2,2))
  window,0
  t=dindgen(ulong(stop_et-start_et)+1)/60d
  plot,t,r,/ynoz
  window,1
  plot,t,v,/ynoz
  s0v=state[minidx,*]
  r0v=s0v[0:2]
  v0v=s0v[3:5]
  cspice_gdpool,'BODY499_GM',0,1,mars_mu,found
  cspice_gdpool,'BODY499_RADII',0,1,mars_r,found
  mars_mu=mars_mu[0]
  mars_r=mars_r[0]
  el=elorb(r0v,v0v,mars_r,mars_mu,ev=ev)
  peri=ev/vlength(ev)*el.rp
  sh=normalize_grid(v0v)
  th=normalize_grid(crossp_grid(sh,[0,0,-1]))
  rh=normalize_grid(crossp_grid(th,sh))
  b=(b_plane(r0v,v0v,mars_r,mars_mu))[0]
  bv=normalize_grid(proj_p(peri,sh))*b
  bdotr=dotp(bv,rh)
  bdott=dotp(bv,th)
  thetab=atan(bdotr,bdott)
  print,bdotr,bdott,thetab*!radeg
  SMa=88761.1d
  SMi=22703.3d
  gamma=-24.20d*!dtor
  wset,2
  device,dec=0
  loadct,39
  s=3d5
  plot,[1d,1]*bdott,[1d,1]*bdotr,xrange=[-s,s],yrange=[s,-s],/iso,xtitle="B.t km",ytitle="B.r km",charsize=2,background=255,color=0,/xs,/ys
  oplot,[1d,1]*bdott,[1d,1]*bdotr,psym=2,color=128
  q=dindgen(!dpi*200)/100d
  print,mars_r
  oplot,cos(q)*mars_r,sin(q)*mars_r,color=254
  for i=1,3 do begin
    x=cos(q)*Sma*i
    y=sin(q)*Smi*i
    oplot,x*cos(-gamma-thetab)+y*sin(-gamma-thetab)+bdott,-x*sin(-gamma-thetab)+y*cos(-gamma-thetab)+bdotr,color=0
  end
end
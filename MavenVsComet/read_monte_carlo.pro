pro read_monte_carlo
  template={ $
  VERSION: 1.0000000e+000, $
  DATASTART: 0L, $
  DELIMITER: 32B, $
  MISSINGVALUE:            !values.f_nan, $
  COMMENTSYMBOL: '', $
  FIELDCOUNT: 5L, $
  FIELDTYPES: [0L,5L,5L,5L,0L], $
  FIELDNAMES: ['FIELD1','x','y','z','FIELD5'], $
  FIELDLOCATIONS: [0L,5L,21L,38L,54L], $
  FIELDGROUPS: [0L,1L,2L,3L,4L] $
}
  pos=read_ascii('pos.txt',template=template)
  vel=read_ascii('vel.txt',template=template)
  AU=149597870.691d
  D=86400d
  state=[[pos.x*AU], $
         [pos.y*AU], $
         [pos.z*AU], $
         [vel.x/1000d*AU/D], $
         [vel.y/1000d*AU/D], $
         [vel.z/1000d*AU/D]]
  help,state
  cspice_gdpool,'BODY10_GM',0,1,sun_mu,found
  sun_mu=sun_mu[0]
  cspice_gdpool,'BODY499_GM',0,1,mars_mu,found
  mars_mu=mars_mu[0]
  cspice_gdpool,'BODY499_RADII',0,1,mars_r,found
  mars_r=mars_r[0]
  el_sun=elorb(state[*,0:2],state[*,3:5],AU,sun_mu,ev=ev)
  start_cal='2456950.3JDTDT'
  cspice_str2et,start_cal,et
  
  cspice_spkezr,'499',et,'ECLIPJ2000','NONE','10',mars_state,ltime
  
  state=state-rebin(transpose(mars_state),n_elements(pos.x),6)
  
  el_mars=elorb(state[*,0:2],state[*,3:5],mars_r,mars_mu,ev=ev)
    
  peri=smult_grid(1d/vlength(ev)*el_mars.rp,ev)
  
  ;Technically, sh is parallel to the incoming asymptote. Here we are using the state at the epoch,
  ;which may be before or after c/a. It's ok since the encounter speed is so high, the maximum deflection of the comet even at 
  ;a grazing orbit is only 0.046deg, so the sh calculated is within that much of correct. All it does is shift the plane ever so
  ;slightly.
  sh=normalize_grid(state[*,3:5])
  th=normalize_grid(crossp_grid(sh,[0,0,-1]))
  rh=normalize_grid(crossp_grid(th,sh))
  ;k axis is away from the sun
  jh=normalize_grid(crossp_grid(sh,mars_state[0:2]))
  kh=normalize_grid(crossp_grid(jh,sh))
  print,"vangle(kh,mars):", !radeg*mean(vangle(kh,mars_state[0:2]))
  b=b_plane(state[*,0:2],state[*,3:5],mars_r,mars_mu)
  bv=smult_grid(b,normalize_grid(proj_p(peri,sh)))
  bdotr=dotp(bv,rh)
  bdott=dotp(bv,th)
  print,"Nominal B: ",mean(b)
  print,"Nominal B.r: ",mean(bdotr)
  print,"Nominal B.t: ",mean(bdott)
  bdotj=dotp(bv,jh)
  bdotk=dotp(bv,kh)
 ; bdotr=bdotr[0:100]
;  bdott=bdott[0:100]
  thetab=atan(bdotr,bdott)
  s=3d5

  device,dec=0
  loadct,39
  erase,color=255  
  plot,bdott,bdotr,psym=3,color=0,xrange=[-s,s],yrange=[s,-s],/iso,/xs,/ys,xtitle="B.t km",ytitle="B.r km",charsize=2,title="Monte Carlo uncertainty",background=255
  ;plot,bdott,bdotr,psym=1,color=0,xrange=[-2d4,1d4],yrange=[1d4,-4d4],/iso,/xs,/ys,xtitle="B.t km",ytitle="B.r km",charsize=2,title="Monte Carlo uncertainty",background=255
  ;oplot,bdott,bdotr,psym=3,color=64;,xrange=[-s,s],yrange=[s,-s];,/iso,xtitle="B.t km",ytitle="B.r km",psym=3,charsize=2,title="Monte Carlo uncertainty
  q=dindgen(!dpi*200)/100d
  oplot,cos(q)*mars_r,sin(q)*mars_r,color=254
  c=cos(q)
  s=sin(q)
  f=[[bdott],[bdotr]]
  xbar=total(f,1)/double(n_elements(bdotr))
  oplot,[1d,1]*xbar[0],[1d,1]*xbar[1],psym=2,color=128,symsize=2
  fac=F - rebin(transpose(xbar),n_elements(bdotr),n_elements(xbar))
  P=(Fac ## transpose(Fac))/(n_elements(bdotr)-1)
  L=P
  la_choldc,L
  n=2
  for i=0,n-2 do L[i+1:*,i]=0
  Y=L ## [[c],[s]]
  for i=1,3 do oplot,i*Y[*,0]+xbar[0],i*Y[*,1]+xbar[1],color=200
end
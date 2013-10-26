function ntohl,data,i
  return,ulong(uint(data[i,*]))*65536+uint(data[i+1,*])
end
pro import_fast
  t0=2019.0;  First data point which sees dynamic acceleration is first point after this time
  swindow,0
  device,dec=1
  data=read_binary('ouf010.sds',data_t=2,endian='big')
  help,data
  data=reform(data,17,n_elements(data)/17)
  seq=ntohl(data,0)
  tcm=fix_tc(/sec,ntohl(data,2))-t0
  max=data[ 4,*]
  may=data[ 5,*]
  maz=data[ 6,*]
  mgx=data[ 7,*]
  mgy=data[ 8,*]
  mgz=data[ 9,*]
  mt =data[10,*]
  hx=data[11,*] mod 4096
  hy=data[12,*] mod 4096
  hz=data[13,*] mod 4096
  tcm1=fix_tc(/sec,ntohl(data,14))-t0
  xrange=[0,923]
  phyrange=160.0
  dnrange=32768.0
  t0g=[130,470]
  w0g=where(tcm gt t0g[0] and tcm lt t0g[1])
  phyrangeh=2000;
  dnrangeh=2048
  hxm=mean(hx[w0g])
  hym=mean(hy[w0g])
  hzm=mean(hz[w0g])
  maxm=mean(max[w0g])
  maym=mean(may[w0g])
  mazm=mean(maz[w0g])
  
  maxf=linfit(mt[w0g],max[w0g],yfit=yfit) & print,"max || ",maxf[0],"||",maxf[1],"||",stdev(max[w0g]),"||",stdev(yfit-max[w0g])
  mayf=linfit(mt[w0g],may[w0g],yfit=yfit) & print,"may || ",mayf[0],"||",mayf[1],"||",stdev(may[w0g]),"||",stdev(yfit-may[w0g])
  mazf=linfit(mt[w0g],maz[w0g],yfit=yfit) & print,"maz || ",mazf[0],"||",mazf[1],"||",stdev(maz[w0g]),"||",stdev(yfit-maz[w0g])
  
  mgxf=linfit(mt[w0g],mgx[w0g],yfit=yfit) & print,"mgx || ",mgxf[0],"||",mgxf[1],"||",stdev(mgx[w0g]),"||",stdev(yfit-mgx[w0g])
  mgyf=linfit(mt[w0g],mgy[w0g],yfit=yfit) & print,"mgy || ",mgyf[0],"||",mgyf[1],"||",stdev(mgy[w0g]),"||",stdev(yfit-mgy[w0g])
  mgzf=linfit(mt[w0g],mgz[w0g],yfit=yfit) & print,"mgz || ",mgzf[0],"||",mgzf[1],"||",stdev(mgz[w0g]),"||",stdev(yfit-mgz[w0g])
  
  maxp=-(max-poly(mt,maxf))*phyrange/dnrange
  mayp= (may-poly(mt,mayf))*phyrange/dnrange
  mazp=-(maz-poly(mt,mazf))*phyrange/dnrange
  matp=sqrt(maxp^2+mayp^2+mazp^2)
  
  plot,tcm, matp,xrange=xrange,yrange=[-phyrange,phyrange]
  oplot,tcm,maxp,color='0000ff'x
  oplot,tcm,mayp,color='00ff00'x
  oplot,tcm,mazp,color='ff0000'x
;  oplot,tcm,(hx-hxm)*phyrangeh/dnrangeh,color='0000ff'x,psym=3
;  oplot,tcm,(hy-hym)*phyrangeh/dnrangeh,color='00ff00'x,psym=3
;  oplot,tcm,(hz-hzm)*phyrangeh/dnrangeh,color='ff0000'x,psym=3
  hxp=(hx-hxm)*phyrangeh/dnrangeh
  hyp=(hy-hym)*phyrangeh/dnrangeh
  hzp=(hz-hzm)*phyrangeh/dnrangeh
  w1s=where(tcm gt 0 and tcm lt 20)
  wm=where(tcm gt -5 and tcm lt 0)
  mazm_onground=mean(maz[wm])
  maz_1s=-(maz[w1s]-mazm_onground)*phyrange/dnrange
  tcm_1s=tcm[w1s]
  dtcm_1s=tcm_1s-shift(tcm_1s,1)
  dtcm_1s=dtcm_1s[1]
  dmaz_1s=maz_1s+shift(maz_1s,1)
  dmaz_1s[0]=0
  mvz_1s=0.5*total(/c,dtcm_1s*dmaz_1s)
  dmvz_1s=mvz_1s+shift(mvz_1s,1)
  dmvz_1s[0]=0
  mrz_1s=0.5*total(/c,dtcm_1s*dmvz_1s)
  plot,tcm_1s,mvz_1s,xrange=[-0.05,0.5]
  dtc=tcm-shift(tcm,1)
  dtc[0]=dtc[1]
  plot,tcm,dtc*1000,yrange=[-50,50]
  plot,tcm,sqrt(hxp^2+hyp^2+hzp^2)
  data=read_binary('ouf00a.sds',data_t=2,endian='big')
  help,data
  data=reform(data,12,n_elements(data)/12)
  tcp=fix_tc(/sec,ntohl(data,2))-t0
  traw=data[ 4,*]
  praw=ntohl(data,5)
  t=data[ 7,*]
  p=ntohl(data,8)
  plot,tcp,p,xrange=xrange
  data=read_binary('ouf004.sds',data_t=2,endian='big')
  help,data
  data=reform(data,7,n_elements(data)/7)
  tcb=fix_tc(/sec,ntohl(data,2))-t0
  bx=data[ 4,*]
  by=data[ 6,*]
  bz=data[ 5,*]
  hrange=[0,575]
  whrange=where(tcb gt hrange[0] and tcb lt hrange[1])
  plot,tcb,bx,xrange=hrange,/xs,yrange=[min([bx,by,bz]),max([bx,by,bz])],psym=3
  oplot,tcb,bx,color='0000ff'x,psym=3
  oplot,tcb,by,color='00ff00'x,psym=3
  oplot,tcb,bz,color='ff0000'x,psym=3
  ellipsoid_fit,bx[whrange],by[whrange],bz[whrange],center=center,radii=radii,evec=evec
  hbx=center[0]
  hby=center[1]
  hbz=center[2]
  bx-=hbx
  by-=hby
  bz-=hbz
  swindow,1
  device,dec=0
  loadct,39
  plot,bx,by,/iso,color=0,background=255,/nodata
  wf=where(tcb gt xrange[0] and tcb lt xrange[1])
  plots,bx[wf],by[wf],color=lindgen(n_elements(wf))*255L/n_elements(wf),psym=1
end
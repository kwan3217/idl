function ntohl,data,i
  return,ulong(uint(data[i,*]))*65536+uint(data[i+1,*])
end
pro import_fast
  data=read_binary('ouf010.sds',data_t=2,endian='big')
  help,data
  data=reform(data,17,n_elements(data)/17)
  seq=ntohl(data,0)
  tc0=fix_tc(/sec,ntohl(data,2))
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
  xrange=[2600,3000]
phyrange=160.0
dnrange=32768.0
t0g=[2200,2400]
w0g=where(tc0 gt t0g[0] and tc0 lt t0g[1])
phyrangeh=2000;
dnrangeh=2048
hxm=mean(hx[w0g])
hym=mean(hy[w0g])
hzm=mean(hz[w0g])
  plot,tc0,maz*phyrange/dnrange,xrange=xrange,yrange=[-phyrange,phyrange],psym=3
  oplot,tc0,max*phyrange/dnrange,color='0000ff'x,psym=3
  oplot,tc0,may*phyrange/dnrange,color='00ff00'x,psym=3
  oplot,tc0,maz*phyrange/dnrange,color='ff0000'x,psym=3
  oplot,tc0,(hx-hxm)*phyrangeh/dnrangeh,color='0000ff'x,psym=3
  oplot,tc0,(hy-hym)*phyrangeh/dnrangeh,color='00ff00'x,psym=3
  oplot,tc0,(hz-hzm)*phyrangeh/dnrangeh,color='ff0000'x,psym=3
  hxp=(hx-hxm)*phyrangeh/dnrangeh
  hyp=(hy-hym)*phyrangeh/dnrangeh
  hzp=(hz-hzm)*phyrangeh/dnrangeh
  dtc=tc0-shift(tc0,1)
  plot,tc0,dtc*1000,yrange=[-50,50]
  data=read_binary('ouf00a.sds',data_t=2,endian='big')
  help,data
  data=reform(data,12,n_elements(data)/12)
  tc0=fix_tc(/sec,ntohl(data,2))
  traw=data[ 4,*]
  praw=ntohl(data,5)
  t=data[ 7,*]
  p=ntohl(data,8)
  plot,tc0/60d,p,xrange=xrange
  data=read_binary('ouf004.sds',data_t=2,endian='big')
  help,data
  data=reform(data,7,n_elements(data)/7)
  tc0=fix_tc(/sec,ntohl(data,2))
  bx=data[ 4,*]
  by=data[ 5,*]
  bz=data[ 6,*]
  plot,tc0,bx,xrange=xrange,yrange=[min([bx,by,bz]),max([bx,by,bz])],psym=3
  oplot,tc0,bx,color='0000ff'x,psym=3
  oplot,tc0,by,color='00ff00'x,psym=3
  oplot,tc0,bz,color='ff0000'x,psym=3
  
end
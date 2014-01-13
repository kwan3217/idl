function linterp,x0,y0,x1,y1,x
  t=(x-x0)/(x1-x0)
  return,y0*(1-t)+y1*t
end

pro needle,scale,width,flength,blength,val0,th0,val1,th1,val,xc,yc,color
    needlex=[double(-width),0,width,0]
    needley=[0d,flength,0,-blength]
    needle=[[needlex],[needley]]
    theta=linterp(val0,th0,val1,th1,val)
    m=[[cos(theta),sin(theta)],[-sin(theta),cos(theta)]]
    needle=m ## needle
    polyfill,/device,(needle[*,0]+xc)*scale,(needle[*,1]+yc)*scale,color=color
end

pro rocket_data_36290,sf,ef
  set_plot,'win'
    fps=30d
  scale=3d
  ttrackend=829.5d
  frame_launch=15217d
  frame_land=43235d
  tland=(frame_land-frame_launch)/fps
  dt_notrack=tland-ttrackend
  tradar_ofs=1.1d
  radar_template={ $
    VERSION: 1.0000000e+000, $
    DATASTART: 1L, $
    DELIMITER: 0B, $
    MISSINGVALUE: !values.f_nan, $
    COMMENTSYMBOL: '', $
    FIELDCOUNT: 21L, $
    FIELDTYPES: [0L,4L,0L,0L,0L,4L,0L,0L,0L,4L,4L,4L,4L,4L,4L,4L,4L,4L,4L,4L,4L], $
    FIELDNAMES: ['FIELD01','Time','FIELD03','FIELD04','FIELD05','gr','FIELD07','FIELD08','FIELD09','alt','lat','lon','tvel','xd','yd','zd','FIELD17','FIELD18','FIELD19','FIELD20','FIELD21'], $
    FIELDLOCATIONS: [0L,   16L,   31L,      41L,       54L,     65L, 82L,      94L,      102L,     112L, 123L, 134L, 151L,  164L,176L,187L,199L,210L,226L,234L,247L], $
    FIELDGROUPS: [0L,1L,2L,3L,4L,5L,6L,7L,8L,9L,10L,11L,12L,13L,14L,15L,16L,17L,18L,19L,20L] $
  }
  hires_data=read_ascii(template=radar_template,'../../Data/Rocketometry/flights/36.290/Terrier Black-Brant Woods 36.290 R971PAY 102113.txt')
  dt_radar=hires_data.time[1]-hires_data.time[0]
  fps_radar=fix(0.5+1.0d/dt_radar)
  n1=(10+hires_data.time[0]+tradar_ofs)*fps_radar
  tradar =dindgen(n1)*dt_radar -10d;time up to and including t-0
  tradar=[tradar,hires_data.time+tradar_ofs];time while tracked
  tradar=[tradar,dindgen(dt_notrack*fps_Radar)*dt_radar +max(tradar)+dt_radar];after tracked to impact
  tradar=[tradar,dindgen(10*fps_radar)*dt_radar +max(tradar)+dt_radar];after impact for 10 seconds
  
  ew_vel =dblarr(n1);before t-0
  ew_vel =[ew_vel,hires_data.xd];time while tracked
  ew_vel =[ew_vel,dblarr(dt_notrack*fps_radar)] ;after tracked to impact
  ew_vel =[ew_vel,dblarr(10*fps_radar)];after impact for 10 seconds

  ns_vel =dblarr(n1);before t-0
  ns_vel =[ns_vel,hires_data.yd];time while tracked
  ns_vel =[ns_vel,dblarr(dt_notrack*fps_radar)] ;after tracked to impact
  ns_vel =[ns_vel,dblarr(10*fps_radar)];after impact for 10 seconds

  alt_trackend=hires_data.alt[-1]
  alt_land=1208
  dalt_notrack=alt_land-alt_trackend
  alt_vel =dblarr(n1);before t-0
  alt_vel =[alt_vel,hires_data.zd];time while tracked
  alt_vel =[alt_vel,dblarr(dt_notrack*fps_radar)+dalt_notrack/dt_notrack] ;after tracked to impact (-5m/s)
  alt_vel =[alt_vel,dblarr(10*fps_radar)];after impact for 10 seconds

  tvel =dblarr(n1);before t-0
  tvel =[tvel,hires_data.tvel];time while tracked
  tvel =[tvel,abs(dblarr(dt_notrack*fps_radar)+dalt_notrack/dt_notrack)] ;after tracked to impact (-5m/s)
  tvel =[tvel,dblarr(10*fps_radar)];after impact for 10 seconds
  w=where(tradar gt 0 and tradar lt hires_data.time[0]+tradar_ofs)
  tvel[w]=dindgen(n_elements(w))/n_elements(w)*tvel[max(w)+1]
  dxd=hires_data.xd-shift(hires_data.xd,1)
  dxd[0]=dxd[1]
  dyd=hires_data.yd-shift(hires_data.yd,1)
  dyd[0]=dyd[1]
  dzd=hires_data.zd-shift(hires_data.zd,1)
  dzd[0]=dzd[1]
  xdd=dxd/dt_radar
  ydd=dyd/dt_radar
  zdd=dzd/dt_radar+9.8
  tacc =dblarr(n1)+9.8;before t-0
  tacc =[tacc,sqrt(xdd^2+ydd^2+zdd^2)];time while tracked
  tacc =[tacc,dblarr(dt_notrack*fps_radar)+9.8] ;after tracked to impact (-5m/s)
  tacc =[tacc,dblarr(10*fps_radar)+9.8];after impact for 10 seconds
  w=where(tradar gt 60 and tradar lt 480)
  tacc[w]=0
  w=where(zdd lt 0 and hires_data.time+tradar_ofs lt 20)+n1
  tacc[w]=-tacc[w]
  w=where(tradar gt 0 and tradar lt tradar_ofs+hires_data.time[0])
  tacc[w]=tacc[max(w)+1]
  alt =[dblarr(n1)+hires_data.alt[0]];before t-0
  alt =[alt,hires_data.alt];time while tracked
  alt =[alt,dindgen(dt_notrack*fps_radar)*dalt_notrack/(dt_notrack*fps_radar)+alt_trackend] ;after tracked to impact (-5m/s)
  alt =[alt,dblarr(10*fps_radar)+alt_land];after impact for 10 seconds

  gr =dblarr(n1);before t-0
  gr =[gr,hires_data.gr];time while tracked
  gr =[gr,dblarr(dt_notrack*fps_radar)+hires_data.gr[-1]] ;after tracked to impact (-5m/s)
  gr =[gr,dblarr(10*fps_radar)+hires_data.gr[-1]];after impact for 10 seconds

  t=dindgen((tland+20)*fps)/double(fps) -10d
  tacc=interpol(tacc,tradar,t)    
  radar_data={time: t, $
                ew_vel:  interpol(ew_vel,tradar,t), $
                ns_vel:  interpol(ns_vel,tradar,t), $
                alt_vel: interpol(alt_vel,tradar,t), $
                alt:     interpol(alt,tradar,t), $
                tvel:    interpol(tvel,tradar,t), $
                gr:      interpol(gr,tradar,t) $
                }
  tvel=radar_data.tvel
  alt=radar_data.alt
  gr=radar_data.gr
  t0_rkto=2019.0;  First data point which sees dynamic acceleration is first point after this time

  data=read_binary('ouf010.sds',data_t=2,endian='big')
  help,data
  data=reform(data,17,n_elements(data)/17)
  seq=ntohl(data,0)
  tcm=fix_tc(/sec,ntohl(data,2))-t0_rkto
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
  tcm1=fix_tc(/sec,ntohl(data,14))-t0_rkto
  xrange=[0,10]
  phyrange=160.0*9.79280914/10.2654
  dnrange=32768.0
  phygrange=2000.0*(218.0/216.25)/360.0;rev/sec
  dngrange=32768.0
  t0g=[130,470]
  w0g=where(tcm gt t0g[0] and tcm lt t0g[1])
  phyrangeh=2000/0.914533;
  dnrangeh=2048
  hxm=mean(hx[w0g])
  hym=mean(hy[w0g])
  hzm=mean(hz[w0g])
  print,"hm",hxm,hym,hzm
  print,"hs",stdev(hx[w0g]),stdev(hy[w0g]),stdev(hz[w0g])
  
  maxf=linfit(mt[w0g],max[w0g],yfit=yfit) & print,"max || ",maxf[0],"||",maxf[1],"||",stdev(max[w0g]),"||",stdev(yfit-max[w0g])
  mayf=linfit(mt[w0g],may[w0g],yfit=yfit) & print,"may || ",mayf[0],"||",mayf[1],"||",stdev(may[w0g]),"||",stdev(yfit-may[w0g])
  mazf=linfit(mt[w0g],maz[w0g],yfit=yfit) & print,"maz || ",mazf[0],"||",mazf[1],"||",stdev(maz[w0g]),"||",stdev(yfit-maz[w0g])
  
  hxf=linfit(mt[w0g],hx[w0g],yfit=yfit) & print,"hx || ",hxf[0],"||",hxf[1],"||",stdev(max[w0g]),"||",stdev(yfit-hx[w0g])
  hyf=linfit(mt[w0g],hy[w0g],yfit=yfit) & print,"hy || ",hyf[0],"||",hyf[1],"||",stdev(may[w0g]),"||",stdev(yfit-hy[w0g])
  hzf=linfit(mt[w0g],hz[w0g],yfit=yfit) & print,"hz || ",hzf[0],"||",hzf[1],"||",stdev(maz[w0g]),"||",stdev(yfit-hz[w0g])
  
  mgxf=linfit(mt[w0g],mgx[w0g],yfit=yfit) & print,"mgx || ",mgxf[0],"||",mgxf[1],"||",stdev(mgx[w0g]),"||",stdev(yfit-mgx[w0g])
  mgyf=linfit(mt[w0g],mgy[w0g],yfit=yfit) & print,"mgy || ",mgyf[0],"||",mgyf[1],"||",stdev(mgy[w0g]),"||",stdev(yfit-mgy[w0g])
  mgzf=linfit(mt[w0g],mgz[w0g],yfit=yfit) & print,"mgz || ",mgzf[0],"||",mgzf[1],"||",stdev(mgz[w0g]),"||",stdev(yfit-mgz[w0g])
  
  maxp= (max-poly(mt,maxf))*phyrange/dnrange
  mayp= (may-poly(mt,mayf))*phyrange/dnrange
  mazp= (maz-poly(mt,mazf))*phyrange/dnrange
  mgxp= (mgx-poly(mt,mgxf))*phygrange/dngrange
  mgyp= (mgy-poly(mt,mgyf))*phygrange/dngrange
  mgzp= (mgz-poly(mt,mgzf))*phygrange/dngrange
  sat=max eq 32767 or max eq -32768 or may eq 32767 or may eq -32768 or maz eq 32767 or maz eq -32768
  boost_sat=sat or tcm lt 0 or tcm gt 1000
  w_sat=where(boost_sat,comp=w_nonsat)
  hxf=linfit(maxp[w_nonsat],hx[w_nonsat],yfit=yfit) & print,"hx || ",hxf[0],"||",hxf[1],"||",stdev(yfit-hx[w_nonsat])
  hyf=linfit(mayp[w_nonsat],hy[w_nonsat],yfit=yfit) & print,"hy || ",hyf[0],"||",hyf[1],"||",stdev(yfit-hy[w_nonsat])
  hzf=linfit(mazp[w_nonsat],hz[w_nonsat],yfit=yfit) & print,"hz || ",hzf[0],"||",hzf[1],"||",stdev(yfit-hz[w_nonsat])
  hxp=(hx-hxf[0])/hxf[1]
  hyp=(hy-hyf[0])/hyf[1]
  hzp=(hz-hzf[0])/hzf[1]
  w_sat=where(sat)
  matp=sqrt(maxp^2+mayp^2+mazp^2)
  mgtp=sqrt(mgxp^2+mgyp^2+mgzp^2)
  w=where(tcm lt 100)
  matp[w]=-mazp[w]
  matp[w_sat]=sqrt(hxp[w_sat]^2+hyp[w_sat]^2+hzp[w_sat]^2)
  plot,t,tacc,xrange=[0,100]
  oplot,tcm,matp,color='0000ff'x

  img=read_png('Rocket Background 36.290.png')
  tacc=interpol(matp,tcm,t)
  w=where(abs(tacc/9.8) lt 0.06) 
  tacc[w]=0 
  img=img[0:2,*,*] ;get rid of alpha channel
  !p.font=1
  charsize=2.0
;  img=rebin(img,[3,1280*scale,720*scale],/sample)
  if n_elements(sf) eq 0 then sf=0
  if n_elements(ef) eq 0 then ef=(tland+20)*fps-1
  if ef gt (tland+20)*fps-1 then ef=(tland+20)*fps-1
  set_plot,'z'
  x0=448
  y0=0
  x1=1136-1
  y1=240-1
  device,set_font='Monospace Symbol',/tt_font,set_resolution=[x1-x0+1,y1-y0+1]*scale,set_pixel_depth=24
  imgsection_big=rebin(/sample,img[*,x0:x1,y0:y1],3,(x1-x0+1)*scale,(y1-y0+1)*scale)
  for i=sf,ef do begin
    tic
    erase
;    toc,'set up display'
    t=double(i)/double(fps) -10d
    hh=string(format='(%"%6.1f")',alt[i]/1000d)
    vv=string(format='(%"%d")',tvel[i])
    gg=string(format='(%"%0.1f")',tacc[i]/9.8)
    if t lt 0 then ts='-' else ts='+'
    mm=fix(abs(t)/60)
    ss=abs(t)-mm*60d
    if(ss gt 59.9) then ss=59.9 
    xyouts,/device,( 900-x0)*scale,(120-y0)*scale,charsize=charsize*scale,gg,color='0101ff'x,align=1 ;acceleration value
    xyouts,/device,(1070-x0)*scale,( 21-y0)*scale,charsize=charsize*scale,hh,color='ffffff'x,align=1 ;altitude value
    xyouts,/device,( 720-x0)*scale,(120-y0)*scale,charsize=charsize*scale,vv,color='ffffff'x,align=0 ;speed value
    xyouts,/device,( 560-x0)*scale,( 50-y0)*scale,charsize=charsize*scale,string(format='(%"%1s%02d:%04.1f")',ts,mm,ss),color='010101'x,align=0.5 ;time display
;    toc,'drew text'
;pro needle,scale,width,flength,blength,val0,        th0,  val1,       th1,         val, xc, yc,color
     needle,scale,    5,     80,     15,  0d,-!dpi*3d/4d, 3000d,!dpi*3d/4d,tvel[i]     ,(810-x0),(120-y0),'ffffff'x ;speed needle
     needle,scale,    5,     50,     15,  0d,-!dpi*3d/4d,   30d,!dpi*3d/4d,tacc[i]/9.8d,(810-x0),(120-y0),'0101ff'x ;acceleration needle
     needle,scale,    5,     50,     15,  0d,         0d,   30d,      !dpi,t/60d       ,(560-x0),(120-y0),'010101'x ;minute needle
     needle,scale,    2,     80,     15,  0d,         0d,   30d,      !dpi,t           ,(560-x0),(120-y0),'0101ff'x ;second needle
;    toc,'drew needles'
    ;parabola display    
    plots,/device,       linterp(-10000d,983d -x0,90000d,983d +140d -x0,gr     )*scale,       linterp(0d,10d -y0,300000d,10d +220d -y0,alt     )*scale,thick=scale,color='808080'x
    plots,/device,       linterp(-10000d,983d -x0,90000d,983d +140d -x0,gr[0:i])*scale,       linterp(0d,10d -y0,300000d,10d +220d -y0,alt[0:i])*scale,thick=scale,color='ffffff'x
    plots,/device,[1d,1]*linterp(-10000d,983d -x0,90000d,983d +140d -x0,gr[i]  )*scale,[1d,1]*linterp(0d,10d -y0,300000d,10d +220d -y0,alt[i]  )*scale,thick=scale,psym=4,symsize=0.5*scale,color='ffffff'x
;    toc,'drew parabola'
    out=tvrd(true=1)
    w=where(out ne 0)
;    toc,'read screen'
    img_out=imgsection_big
    img_out[w]=out[w]
;    toc,'wrote on background'
    img_out=rebin(temporary(img_out),3,(x1-x0+1),(y1-y0+1))
;    toc,'resized'
;    toc,'displayed'
    write_png,string(i,format='(%"Frames/frame%05d.png")'),img_out
    if i mod fps eq 0 then begin
      set_plot,'win'
      tv,true=1,img_out
      wait,0.01
      set_plot,'z'
      toc,string(format='(%"%1s%02d:%04.1f")',ts,mm,ss)
    end
  end
  stop
end
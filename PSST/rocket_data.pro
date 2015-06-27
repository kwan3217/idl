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

pro rocket_data,sf,ef
  set_plot,'z'
    fps=30
  scale=3d
  if 0 then begin
   radar_template={ $
    VERSION: 1.0000000e+000, $
    DATASTART: 3L, $
    DELIMITER: 32B, $
    MISSINGVALUE:        !values.f_nan, $
    COMMENTSYMBOL: '', $
    FIELDCOUNT: 12L, $
    FIELDTYPES: [7L,4L,4L,4L,3L,4L,4L,4L,4L,5L,5L,4L], $
    FIELDNAMES: ['UTC','TSL','az_f_lau','gr','vel','x_local','y_local','z_local','msl','lat','lon','l_o_1'], $
    FIELDLOCATIONS: [0L,20L,29L,42L,55L,62L,73L,85L,94L,103L,112L,129L], $
    FIELDGROUPS: [0L,1L,2L,3L,4L,5L,6L,7L,8L,9L,10L,11L] $
  }
    payload_data=read_ascii(template=radar_template,'ae80415B_Print1_1')
    stage_data=read_ascii(template=radar_template,'ae80415B_Print2_1')
    e=payload_data.x_local*1609.344
    n=payload_data.y_local*1609.344
    u=payload_data.z_local*1609.344
    hh=long(strmid(payload_data.utc,0,2))
    mm=long(strmid(payload_data.utc,3,2))
    ss=float(strmid(payload_data.utc,6,4))
    sod=hh*3600L+mm*60L+ss
    met=sod-sod[11]
    dt=met-shift(met,1) & dt[0]=dt[1]
    de=e-shift(e,1) & de[0]=de[1]
    dn=n-shift(n,1) & dn[0]=dn[1]
    du=u-shift(u,1) & du[0]=du[1]
    ew_vel=de/dt
    ns_vel=dn/dt
    alt_vel=du/dt
    tp=      [0,5.5, 12, 25,  30,  40,  46,  48,  500,  510,  520, 525, 530, 540,635, 660, 950,951,1000]
    alt_velp=[0,600,450,850,1050,1700,2080,2100,-2050,-1800,-1400,-700,-200,-150,-25,-8.4,-8.4,  0,   0]
    ns_velp= [0, 40, 30, 55,  70, 130, 150, 164,140.6,  140,   90,   0, -30,   0,  0,   0,   0,  0,   0]
    ew_velp= [0,-13,-13,-13, -13, -13, -13, -13,  -13,  -13,  -13, -13,  -5,  -5, -5,   0,   0,  0,   0]
    t=dindgen(971*fps+1)/double(fps) -10d
    w=where(t lt 0)
    alt_vel=interpol(alt_velp,tp,t)
    alt_vel[w]=0
    ns_vel=interpol(ns_velp,tp,t)
    ns_vel[w]=0
    ew_vel=interpol(ew_velp,tp,t)
    ew_vel[w]=0
    alt=interpol(payload_data.msl,met,t)
    alt[w]=alt[100]
    tvel=sqrt(ew_vel^2+ns_vel^2+alt_vel^2)
    gr=interpol(smooth(payload_data.gr,10),met,t)
    radar_data={time: t, $
                ew_vel:  ew_vel, $
                ns_vel:  ns_vel, $
                alt_vel: alt_vel, $
                alt: alt, $
                tvel:tvel, $
                lat:interpol(payload_data.lat,met,t), $
                lon:interpol(payload_data.lon,met,t), $
                gr:gr $
                }

  dt=radar_data.time-shift(radar_data.time,1) & dt[0]=dt[1]
  tvel=sqrt(radar_data.ew_vel^2+radar_data.ns_vel^2+radar_data.alt_vel^2)
  dxv=radar_data.ew_vel-shift(radar_data.ew_vel,1) & dxv[0]=dxv[1]
  dyv=radar_data.ns_vel-shift(radar_data.ns_vel,1) & dyv[0]=dyv[1]
  dzv=radar_data.alt_vel-shift(radar_data.alt_vel,1) & dzv[0]=dzv[1]
  at=radar_data.time
  avx=radar_data.ew_vel
  avy=radar_data.ns_vel
  avz=radar_data.alt_vel
  adt=at-shift(at,1) & adt[0]=adt[1]
  advx=avx-shift(avx,1) & advx[0]=advx[1]
  advy=avy-shift(avy,1) & advy[0]=advy[1]
  advz=avz-shift(avz,1) & advz[0]=advz[1]
  ax=advx/adt
  ay=advy/adt
  az=advz/adt
  az=az+9.8
  tacc=sqrt(ax^2+ay^2+az^2)
  tacc=interpol(tacc,at,radar_data.time)
  w=where(radar_data.time lt 0)
  tacc[w]=9.8
;  w=where(radar_data.time gt 50 and radar_data.time lt 475)
;  tacc[w]=0
;  w=where(abs(tacc-shift(tacc,1)) gt 0.1 or indgen(n_elements(tacc)) mod (fps*30) eq 0)
;  tacc=interpol(tacc[w],t[w],t)
;  tacc=tacc>0
  w=where(radar_data.time lt 0)
  tacc[w]=9.8
  w=where(t gt 0 and t lt 6)
  tacc[w]=linterp(0d,110d,6d,130d,t[w])
  w=where(t gt 6 and t lt 12)
  tacc[w]=linterp(6d,20d,12d,18d,t[w])
  end else begin
    radar_template={ $
      VERSION: 1.0000000e+000, $
      DATASTART: 1L, $
      DELIMITER: 44B, $
      MISSINGVALUE:            !values.f_nan, $
      COMMENTSYMBOL: '', $
      FIELDCOUNT: 17L, $
      FIELDTYPES: [4L,5L,5L,5L,5L,5L,5L,5L,4L,0L,0L,0L,0L,4L,4L,4L,0L], $
      FIELDNAMES: ['time','lat','lon','alt','tvel','xd','yd','zd','gr','FIELD10','FIELD11','FIELD12','FIELD13','xdd','ydd','zdd','FIELD17'], $
      FIELDLOCATIONS: [0L,5L,17L,30L,38L,44L,50L,56L,63L,68L,73L,78L,83L,88L,92L,96L,101L], $
      FIELDGROUPS: [0L,1L,2L,3L,4L,5L,6L,7L,8L,9L,10L,11L,12L,13L,14L,15L,16L] $
    }
    hires_data=read_ascii(template=radar_template,'Rocket36.286 detailed radar payload.csv')

    tradar =[dindgen(10*20+1)/20d -10d];time up to and including t-0
    tradar=[tradar,hires_data.time];time while tracked
    tradar=[tradar,dindgen(961L*20-n_elements(tradar))/20d +max(tradar)+0.05];after tracked to impact
    tradar=[tradar,dindgen(10*20)/20d +max(tradar)+0.05];after impact for 10 seconds

     ew_vel =[dblarr(10*20+1)];before t-0
    ew_vel =[ew_vel,hires_data.xd];time while tracked
    ew_vel =[ew_vel,dblarr(961L*20-n_elements(ew_vel))] ;after tracked to impact
    ew_vel =[ew_vel,dblarr(10*20)];after impact for 10 seconds

    ns_vel =[dblarr(10*20+1)];before t-0
    ns_vel =[ns_vel,hires_data.yd];time while tracked
    ns_vel =[ns_vel,dblarr(961L*20-n_elements(ns_vel))] ;after tracked to impact
    ns_vel =[ns_vel,dblarr(10*20)];after impact for 10 seconds

    alt_vel =[dblarr(10*20+1)];before t-0
    alt_vel =[alt_vel,hires_data.zd];time while tracked
    alt_vel =[alt_vel,dblarr(961L*20-n_elements(alt_vel))-5] ;after tracked to impact (-5m/s)
    alt_vel =[alt_vel,dblarr(10*20)];after impact for 10 seconds

    tvel =[dblarr(10*20+1)];before t-0
    tvel =[tvel,hires_data.tvel];time while tracked
    tvel =[tvel,dblarr(961L*20-n_elements(tvel))+5] ;after tracked to impact (-5m/s)
    tvel =[tvel,dblarr(10*20)];after impact for 10 seconds

    tacc =[dblarr(10*20+1)+9.8];before t-0
    tacc =[tacc,sqrt(hires_data.xdd^2+hires_data.ydd^2+hires_data.zdd^2)];time while tracked
    tacc =[tacc,dblarr(961L*20-n_elements(tacc))+9.8] ;after tracked to impact (-5m/s)
    tacc =[tacc,dblarr(10*20)+9.8];after impact for 10 seconds
    w=where(tradar gt 50 and tradar lt 495)
    tacc[w]=0
    alt =[dblarr(10*20+1)+hires_data.alt[0]];before t-0
    alt =[alt,hires_data.alt];time while tracked
    alt =[alt,dblarr(961L*20-n_elements(alt))+1200] ;after tracked to impact (-5m/s)
    alt =[alt,dblarr(10*20)+1200];after impact for 10 seconds

    gr =[dblarr(10*20+1)];before t-0
    gr =[gr,hires_data.gr];time while tracked
    gr =[gr,dblarr(961L*20-n_elements(gr))+max(gr)] ;after tracked to impact (-5m/s)
    gr =[gr,dblarr(10*20)+max(gr)];after impact for 10 seconds

    t=dindgen(971*fps)/double(fps) -10d
    tacc=interpol(tacc,tradar,t)    
    radar_data={time: t, $
                ew_vel:  interpol(ew_vel,tradar,t), $
                ns_vel:  interpol(ns_vel,tradar,t), $
                alt_vel: interpol(alt_vel,tradar,t), $
                alt:     interpol(alt,tradar,t), $
                tvel:    interpol(tvel,tradar,t), $
                gr:      interpol(gr,tradar,t) $
                }
  end
  tvel=radar_data.tvel
  img=read_png('Rocket Background.png')
  img=img[0:2,*,*] ;get rid of alpha channel
  !p.font=1
  charsize=2.0
  device,set_font='Monospace Symbol',/tt_font,set_resolution=[1280,720]*scale,set_pixel_depth=24
  img=rebin(img,[3,1280*scale,720*scale],/sample)
  if n_elements(sf) eq 0 then sf=0
  if n_elements(ef) eq 0 then ef=971*fps
  if ef gt 971*fps then ef=971*fps
  for i=sf,ef do begin
    erase
    t=double(i)/double(fps) -10d
    hh=string(format='(%"%6.1f")',radar_data.alt[i]/1000d)
    vv=string(format='(%"%d")',tvel[i])
    gg=string(format='(%"%0.1f")',tacc[i]/9.8)
    if t lt 0 then ts='-' else ts='+'
    mm=fix(abs(t)/60)
    ss=abs(t)-mm*60d
    xyouts,/device, 900*scale,120*scale,charsize=charsize*scale,gg,color='0101ff'x,align=1 ;acceleration value
    xyouts,/device,1070*scale, 21*scale,charsize=charsize*scale,hh,color='ffffff'x,align=1 ;altitude value
    xyouts,/device, 720*scale,120*scale,charsize=charsize*scale,vv,color='ffffff'x,align=0 ;speed value
    xyouts,/device, 560*scale, 50*scale,charsize=charsize*scale,string(format='(%"%1s%02d:%04.1f")',ts,mm,ss),color='010101'x,align=0.5 ;time display
    
;pro needle,scale,width,flength,blength,val0,        th0,  val1,       th1,         val, xc, yc,color
     needle,scale,    5,     50,     15,  0d,-!dpi*3d/4d,   30d,!dpi*3d/4d,tacc[i]/9.8d,810,120,'0101ff'x ;acceleration needle
     needle,scale,    5,     80,     15,  0d,-!dpi*3d/4d, 3000d,!dpi*3d/4d,tvel[i]     ,810,120,'ffffff'x ;speed needle
     needle,scale,    5,     50,     15,  0d,         0d,   30d,      !dpi,t/60d       ,560,120,'010101'x ;minute needle
     needle,scale,    2,     80,     15,  0d,         0d,   30d,      !dpi,t           ,560,120,'0101ff'x ;second needle

    ;parabola display    
    plots,/device,       linterp(-10000d,983d,90000d,983d +140d,radar_data.gr     )*scale,       linterp(0d,10d,300000d,10d +220d,radar_data.alt     )*scale,thick=scale,color='808080'x
    plots,/device,       linterp(-10000d,983d,90000d,983d +140d,radar_data.gr[0:i])*scale,       linterp(0d,10d,300000d,10d +220d,radar_data.alt[0:i])*scale,thick=scale,color='ffffff'x
    plots,/device,[1d,1]*linterp(-10000d,983d,90000d,983d +140d,radar_data.gr[i]  )*scale,[1d,1]*linterp(0d,10d,300000d,10d +220d,radar_data.alt[i]  )*scale,thick=scale,psym=4,symsize=0.5*scale,color='ffffff'x
    
    out=tvrd(true=1)
    w=where(out ne 0)
    img_out=img
    img_out[w]=out[w]
    img_out=rebin(temporary(img_out),3,1280,720)
    write_png,string(i,format='(%"Frames/frame%05d.png")'),img_out
    if i mod fps eq 0 then print,string(format='(%"%1s%02d:%04.1f")',ts,mm,ss)
  end
  stop
end
pro iuvs_test_com
  result=eve_read_whole_fits('c:\users\jeppesen\Desktop\FUV_0001_0_387515615.fits')
  device,decompose=0
  loadct,39
  img=long(result.primary)
  
  img2=dblarr(128,128)
  img2[*,64-11:127]=img[*,0:63+11]
  img2[*,0:63-11]=img2[*,64+11:127]

  
  img_unbin=rebin(img2,1024,1024)
  plot,total(img_unbin,1)
  yw=intarr(512)+1024/512
  yt=intarr(512)+1
  xw=intarr(8)+1024/8
  xt=intarr(8)+1
    
  in=bellcurve(dindgen(100),50,50)
  sh=dindgen(100)*512d/100d -256d
  sh[50]=0
  x_com=dblarr(100);
  y_com=x_com
  y_max=x_com
  dark=x_com
  tot=x_com;
  for i=0,99 do begin
    img_bin=iuvs_bin(in[i]*shift(img_unbin,0,sh[i]),xw=xw,xt=xt,yw=yw,yt=yt)
    w=where(img_bin lt quantile(img_bin,0.95))
;    dark[i]=median(img_bin[w])
;    img_bin=long(img_bin)-dark[i]
    img_bin=ulong((long(img_bin)-max(img_bin[w]))>0)
    s=size(img_bin,/dim)
    junk=max(total(img_bin,1),this_y_max)
    y_max[i]=this_y_max
    ww=20
    ;img_com=img_bin[*,y_max[i]-ww:y_max[i]+ww]
    ;x_com[i]=total(total(img_com,2)*dindgen(s[0]))/total(img_com)
    ;y_com[i]=total(total(img_com,1)*dindgen(s[1]))/total(img_com)+y_max[i]-ww
    x_com[i]=total(total(img_bin,2)*dindgen(s[0]))/total(img_bin)
    y_com[i]=total(total(img_bin,1)*dindgen(s[1]))/total(img_bin)
    tot[i]=total(img_bin)
    print,x_com[i],y_com[i],tot[i]
    ;plot,total(img_bin,1)
    ;plots,[1d,1]*y_com[i],[1d,1]*0,psym=1,color=254
    s=size(img_bin,/dim)
    tvscl,congrid(img_bin,1024,1024)
    plots,[1d,1]*x_com[i]*1024/s[0],[1d,1]*(y_com[i])*1024/s[1],psym=1,symsize=10,/dev
  end
  stop
  plot,sh,y_com
end
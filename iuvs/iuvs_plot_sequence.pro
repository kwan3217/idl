pro iuvs_plot_sequence
  f=iuvs_get_files()
  for i=0,n_elements(f)-1 do begin
    if n_elements(h) eq 0 then h=iuvs_read_header(f[i]) else h=[h,iuvs_read_header(f[i])]
  end
  s=sort(h.timestamp)
  h=h[s]
  f=f[s]
  if 0 then begin
    wf=where(h.xuv eq 'FUV',countf)
    wm=where(h.xuv eq 'MUV',countm)
    if countf gt 0 then begin
      hf=h[wf]
      ff=f[wf]
    end
    if countm gt 0 then begin
      hm=h[wm]
      fm=f[wm]
    end
    wset,0
    plot,hm.image_number
    oplot,hm.bin_x_row,color=254
    xt=lonarr(n_elements(hm))
    yt=lonarr(n_elements(hm))
    for i=0,n_elements(hm)-1 do begin
      iuvs_get_row,hm[i].bin_x_row,x_t=this_xt,y_t=this_yt
      xt[i]=total(this_xt)
      yt[i]=total(this_yt)
    end
    wset,1
    plot,hm.length,/ylog
    oplot,xt*yt,color=254
    print,hm.length-xt*yt
    for i=0,n_elements(f)-1 do iuvs_to_fits,f[i]
  end
;  window,2,xsize=512*3,ysize=512+60
  wset,2
  device,decompose=0
  loadct,39
  for i=0,n_elements(f)-1 do begin
    erase
    img=iuvs_read_img(f[i])
    if h[i].bin_type eq 'NON LINEAR' then begin
      if 1 then begin
        s=size(img,/dim)
;        img=iuvs_bin(img,row=h[i].bin_x_row,/inverse)
        tv,img[0:s[0]-1,0:s[1]-1]/256
        xyouts,10,515,string(format='(%"%s - bin %d")',f[i],h[i].bin_x_row),/device
;        s=[8,8]
        if s[0]*s[1] lt 1000 then begin
          for xdif=0,s[0]-1 do begin
            for ydif=0,s[1]-1 do begin
              xyouts,0+(double(xdif)+0.5)*512/s[0],(double(ydif)+0.5)*512/s[1],string(format='(%"%04x")',img[xdif,ydif]),/device,align=0.5
            end
          end
        end
        tpi=iuvs_bin(iuvs_test_pattern(header=h[i]),row=h[i].bin_x_row,/bounds,compress=h[i].data_compression)
;        tpi=iuvs_bin(tpi,row=h[i].bin_x_row,/inverse)
        tv,tpi[0:s[0]-1,0:s[1]-1]/256,512+10,0
        if s[0]*s[1] lt 1000 then begin
          for xdif=0,s[0]-1 do begin
            for ydif=0,s[1]-1 do begin
              xyouts,512+10+(double(xdif)+0.5)*512/s[0],(double(ydif)+0.5)*512/s[1],string(format='(%"%04x")',tpi[xdif,ydif]),/device,align=0.5
            end
          end
        end
        dif=(long(img) - long(tpi))
        adif=dif[0:s[0]-1,0:s[1]-1]*255
        pdif=adif>0<255
        ndif=(-adif)>0<255
        ddif=[[[ndif]],[[pdif]],[[ndif*0]]]
        tv,ddif, 1024+20,0,true=3
        
        if s[0]*s[1] lt 1000 then begin
          for xdif=0,s[0]-1 do begin
            for ydif=0,s[1]-1 do begin
              xyouts,1024+20+(double(xdif)+0.5)*512/s[0],(double(ydif)+0.5)*512/s[1],string(format='(%"%d")',dif[xdif,ydif]),/device,align=0.5
            end
          end
        end
        xyouts,512-1,515,/device,"Hardware",align=1.0
        xyouts,512*2-1,515,/device,"IDL binning",align=1.0
        xyouts,512*3-1,515,/device,"Hardware greater=green, IDL greater=red, same=black",align=1.0
      end else begin
        tpi=iuvs_bin(iuvs_test_pattern(header=h[i]),row=h[i].bin_x_row,/bounds)
        !p.multi=[0,3,1]
        surface,double(img)/1024d,xtitle='spectral',ytitle='spatial',charsize=10,title='Hardware'
        surface,double(tpi)/1024d,xtitle='spectral',ytitle='spatial',charsize=10,title='IDL binning'
        surface,double(long(img)-long(tpi))/1024d ,xtitle='spectral',ytitle='spatial',charsize=10,title='Difference Hardware-IDL'
      end
    end else begin
      tvscl,congrid(img,512,512)
      tpi=iuvs_test_pattern(header=h[i])
      tvscl,congrid(tpi,512,512),512,0
      tv,congrid((tpi ne img) * 255,512,512), 1024,0 
      xyouts,512-1,515,/device,"Hardware",align=1.0
      xyouts,512*2-1,515,/device,"IDL binning",align=1.0
      xyouts,512*3-1,515,/device,"Different=white, same=black",align=1.0
    end
    img=tvrd(/true)
    img=img[*,0:512*3-1+15,0:530]
    write_png,"compare_"+f[i]+".png",img
  end
end
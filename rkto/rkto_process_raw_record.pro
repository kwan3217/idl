;Input: 
; f - filename of raw record file to process
pro rkto_process_raw_record,f
  tic
  openr,inf,f,/get_lun
  status=1
  def=rkto_packet_defs()
  n_packets=ulonarr(2048)
  t_packets=0UL
  while status do begin
    pkt=read_raw_packet(inf=inf,def,skip=0,status=status,/need_apid)
    if status eq 1 then begin
      t_packets+=1
      if(t_packets mod 1000 eq 0) then begin
        toc,string(t_packets)
        if t_packets mod 100000 eq 0 then stop
      end
      n_packets[pkt.apid]=n_packets[pkt.apid]+1
      case pkt.apid of
        1:begin
          if n_elements(adx) eq 0 then adx=pkt
          while n_elements(adx) le n_packets[pkt.apid] do adx=[adx,adx]
          adx[n_packets[pkt.apid]-1]=pkt
        end
        2:help,pkt,/str
        3:begin
          if n_elements(dumpdata) eq 0 then dumpdata=pkt.data else dumpdata=[dumpdata,pkt.data]
        end
        17:begin
          if n_elements(sddata) eq 0 then sddata=pkt.rec else sddata=[sddata,pkt.rec]
        end
        4:begin
          if n_elements(hmc) eq 0 then hmc=pkt
          while n_elements(hmc) le n_packets[pkt.apid] do hmc=[hmc,hmc]
          hmc[n_packets[pkt.apid]-1]=pkt
        end
        5:begin
          if n_elements(l3g) eq 0 then l3g=pkt
          while n_elements(l3g) le n_packets[pkt.apid] do l3g=[l3g,l3g]
          l3g[n_packets[pkt.apid]-1]=pkt
        end
        6:begin
          if n_elements(mpu) eq 0 then mpu=pkt
          while n_elements(mpu) le n_packets[pkt.apid] do mpu=[mpu,mpu]
          mpu[n_packets[pkt.apid]-1]=pkt
        end
        7:begin
          if n_elements(bmp) eq 0 then bmp=pkt
          while n_elements(bmp) le n_packets[pkt.apid] do bmp=[bmp,bmp]
          bmp[n_packets[pkt.apid]-1]=pkt
        end
        8:begin
          if n_elements(tcc) eq 0 then tcc=pkt
          while n_elements(tcc) le n_packets[pkt.apid] do tcc=[tcc,tcc]
          tcc[n_packets[pkt.apid]-1]=pkt
        end
        10:begin
          if n_elements(bmp2) eq 0 then bmp2=pkt
          while n_elements(bmp2) le n_packets[pkt.apid] do bmp2=[bmp2,bmp2]
          bmp2[n_packets[pkt.apid]-1]=pkt
        end
        11:begin
          if n_elements(ad377) eq 0 then ad377=pkt
          while n_elements(ad377) le n_packets[pkt.apid] do ad377=[ad377,ad377]
          ad377[n_packets[pkt.apid]-1]=pkt
        end
        16:begin
          if n_elements(fast) eq 0 then fast=pkt
          while n_elements(fast) le n_packets[pkt.apid] do fast=[fast,fast]
          fast[n_packets[pkt.apid]-1]=pkt
        end
        else:help,pkt,/str
      end
    end
  end
  help,fstat(inf),/str
  close,inf
  free_lun,inf
  if n_packets[1] gt 0 then adx=adx[0:n_packets[1]-1]
  if n_packets[4] gt 0 then hmc=hmc[0:n_packets[4]-1]
  if n_packets[5] gt 0 then l3g=l3g[0:n_packets[5]-1]
  if n_packets[6] gt 0 then mpu=mpu[0:n_packets[6]-1]
  if n_packets[7] gt 0 then bmp=bmp[0:n_packets[7]-1]
  if n_packets[10] gt 0 then bmp2=bmp2[0:n_packets[10]-1]
  if n_packets[8] gt 0 then tcc=tcc[0:n_packets[8]-1]
  if n_packets[11] gt 0 then ad377=ad377[0:n_packets[11]-1]
  if n_packets[16] gt 0 then fast=fast[0:n_packets[16]-1]
  if n_elements(dumpdata) gt 0 then begin
    openw,/get_lun,ouf,f+'.tar.zpaq'
    writeu,ouf,dumpdata
    free_lun,ouf
  end
  toc
  stop
end

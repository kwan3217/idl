;Input: 
; f - filename of raw record file to process
; lin= - optional. If set, this is the path to a cstol script with linear 
;        binning commands, to be used to set up the linear binning table
; non= - optional. If set, path to a folder containing cstol scripts of 
;        the form [spat|spec]%02d.prc defining the nonlinear binning table
pro rkto_process_raw_record,f
  openr,inf,f,/get_lun
  status=1
  def=rkto_packet_defs()
  n_packets=ulonarr(2048)
  t_packets=0UL
  while status do begin
    pkt=read_raw_packet(inf=inf,def,skip=0,status=status)
    if status eq 1 then begin
      t_packets+=1
      if(t_packets mod 1000 eq 0) then print,t_packets
      n_packets[pkt.apid]=n_packets[pkt.apid]+1
      case pkt.apid of
        1:begin
          if n_elements(adx) eq 0 then adx=pkt
          while n_elements(adx) le n_packets[pkt.apid] do adx=[adx,adx]
          adx[n_packets[pkt.apid]-1]=pkt
        end
        2:help,pkt,/str
        3:if n_elements(dumpdata) eq 0 then dumpdata=pkt.data else dumpdata=[dumpdata,pkt.data]
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
        else:help,pkt,/str
      end
    end
  end
  close,inf
  free_lun,inf
  if n_packets[1] gt 0 then adx=adx[0:n_packets[1]-1]
  if n_packets[4] gt 0 then hmc=hmc[0:n_packets[4]-1]
  if n_packets[5] gt 0 then l3g=l3g[0:n_packets[5]-1]
  if n_packets[6] gt 0 then mpu=mpu[0:n_packets[6]-1]
  if n_packets[7] gt 0 then bmp=bmp[0:n_packets[7]-1]
  if n_packets[8] gt 0 then tcc=tcc[0:n_packets[8]-1]
  stop
end

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
  while status do begin
    pkt=read_raw_packet(inf=inf,def,skip=0,status=status)
    if status eq 1 then begin
      case pkt.apid of
        3:if n_elements(dumpdata) eq 0 then dumpdata=pkt.data else dumpdata=[dumpdata,pkt.data]
        2:help,pkt,/str
        1:if n_elements(adxl) eq 0 then adxl=pkt else adxl=[adxl,pkt]
        4:if n_elements(hmc) eq 0 then hmc=pkt else hmc=[hmc,pkt]
        5:if n_elements(l3g) eq 0 then l3g=pkt else l3g=[l3g,pkt]
        6:if n_elements(mpu) eq 0 then mpu=pkt else mpu=[mpu,pkt]
        7:if n_elements(bmp) eq 0 then bmp=pkt else bmp=[bmp,pkt]
        else:help,pkt,/str
      end
    end
  end
  close,inf
  free_lun,inf
  stop
end

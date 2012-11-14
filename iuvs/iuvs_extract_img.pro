function iuvs_extract_img,inf=inf,pkt=pkt,_extra=extra,status=status
  done=0
  status=1
  def=iuvs_packet_definitions2()
  pixels=0
  expectedSegment=0
  
  while ~done and status do begin
    repeat begin
      skip=4
      pkt=read_raw_packet(inf=inf,def,skip=skip,status=status)
    end until pkt.apid eq 7 or status eq 0
    if status then begin
      if pkt.sci_seg_num ne expectedSegment then message,/info,string(format='(%"Segments out of order: Expected %d, saw %d")',expectedSegment,pkt.sci_seg_num)
      expectedSegment=pkt.sci_seg_num+1
      if n_elements(data) eq 0 then begin
        data=pkt.sci_img_data
      end else begin
        data=[data,pkt.sci_img_data]
      end
      pixels+=n_elements(pkt.sci_img_data)/2
      done=(pixels eq pkt.length)
      if pixels gt pkt.length then message,"Huh?"
    end
  end
  if status then begin
    pkt=create_struct(pkt,'timestamp',iuvs_timestamp(pkt.start_time,pkt.start_time__sub,pkt.cadence,pkt.image_number))
    pkt=create_struct(pkt,'mirror_this_dn',pkt.mirror_pos+(pkt.image_number+1)*pkt.step_size)
    a0=12939d
    a1=364.0889d
    pkt=create_struct(pkt,'mirror_this_deg',(double(pkt.mirror_this_dn-a0)/a1))
    pkt=create_struct(pkt,'fov_this_deg',2d*pkt.mirror_this_deg)
  
    data=swap_endian(uint(data,0,pkt.length),/swap_if_little)
    img=iuvs_read_img(header=pkt,a=data,_extra=extra)
    iuvs_to_fits_1a,header=pkt,img=img,_extra=extra
    return,img
  end else return,0
end

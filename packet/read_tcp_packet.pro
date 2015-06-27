function read_tcp_packet,valid=valid,recognized=recognized,pkt_def
  ;Read CCSDS header
  valid=0
  recognized=0
  status=read_bytes(6,header)
  ;Don't bother if there's nothing to read
  if status then begin
    valid=check_ccsds(header,pkt_def,pkt_idx=pkt_idx,length=length,header=header_decom)
    if valid then begin
      status=read_bytes(length+1,body)
      if status eq 0 then message,"read_bytes of body didn't work"
      if(pkt_idx) ge 0 then begin
        recognized=1
        packet=[header,body]
        ;save the raw bytes of recognized packets to a 'raw output' file
        return,parse_pkt(packet,0,pkt_def[pkt_idx])
      end else begin
        return,create_struct(header_decom,'body',body)
      end
    end
  end
end

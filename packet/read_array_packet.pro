;Read the next packet from a raw binary file or other data source
;input
;  inf= - logical unit number opened for binary read and positioned at the 
;         beginning of a (candidate) packet. If not set, use read_bytes() 
;         function to get bytes from some other data source
;  pkt_def - array of packet definitions
;output - 

function read_array_packet,in,valid=valid,recognized=recognized,pkt_def,skip=skip_,need_sec=need_sec,need_grp=need_grp
  ;Read CCSDS header
  valid=0
  recognized=0
  if n_elements(skip_) eq 0 then skip=0 else skip=skip_
  header=in[skip:skip+pkt_def[0].length-1]
  valid=check_ccsds(header,pkt_def,pkt_idx=pkt_idx,length=length,header=header_decom,need_sec=need_sec,need_grp=need_grp)
  if ~valid then return,{apid:0}
  body=in[skip+pkt_def[0].length:skip+pkt_def[0].length+length]
  if(pkt_idx) ge 0 then begin
    recognized=1
    packet=[header,body]
    ;save the raw bytes of recognized packets to a 'raw output' file
    return,parse_pkt(packet,0,pkt_def[pkt_idx])
  end else begin
    return,create_struct(header_decom,'body',body)
  end
end

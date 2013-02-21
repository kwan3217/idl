;Read the next packet from a raw binary file or other data source
;input
;  inf= - logical unit number opened for binary read and positioned at the 
;         beginning of a (candidate) packet. If not set, use read_bytes() 
;         function to get bytes from some other data source
;  pkt_def - array of packet definitions
;output - 

function read_raw_packet,inf=inf,valid=valid,recognized=recognized,pkt_def,skip=skip,status=status,need_sec=need_sec,need_grp=need_grp
  ;Read CCSDS header
  valid=0
  recognized=0
  if n_elements(skip) gt 0 then if skip gt 0 then status=read_raw_bytes(inf,skip,junk)
  if n_elements(inf) gt 0 then begin
    status=read_raw_bytes(inf,pkt_def[0].length,header)
  end else begin
    status=read_bytes(pkt_def[0].length,header)
  end
  ;Don't bother if there's nothing to read
  if ~status then return,{apid:0}
  valid=check_ccsds(header,pkt_def,pkt_idx=pkt_idx,length=length,header=header_decom,need_sec=need_sec,need_grp=need_grp)
  if n_elements(skip) eq 0 then skip=0
  while ~valid do begin
    skip++
    if n_elements(inf) gt 0 then begin
      status=read_raw_bytes(inf,1,this_header)
    end else begin
      status=read_bytes(1,this_header)
    end
  if ~status then return,{apid:0}
    header=[header[1:n_elements(header)-1],this_header]
    valid=check_ccsds(header,pkt_def,pkt_idx=pkt_idx,length=length,header=header_decom,need_sec=need_sec,need_grp=need_grp)
  end
  if n_elements(inf) gt 0 then begin
    status=read_raw_bytes(inf,length+1,body)
  end else begin
    status=read_bytes(length+1,body)
  end
  if status eq 0 then begin
    message,/info,"read_bytes of body didn't work"
    valid=0
    return,{apid:0}
  end
  if(pkt_idx) ge 0 then begin
    recognized=1
    packet=[header,body]
    ;save the raw bytes of recognized packets to a 'raw output' file
    return,parse_pkt(packet,0,pkt_def[pkt_idx])
  end else begin
    return,create_struct(header_decom,'body',body)
  end
end

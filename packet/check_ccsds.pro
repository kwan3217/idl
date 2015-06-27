;Check if the data array starts with a CCSDS header, and if so
;what kind of packet it is.
;
;  in
;    data    - array of bytes, at least six bytes long
;    pkt_def - array of packet definition structures
;  out
;    length= - CCSDS packet length. This is set if there appears
;              to be a valid packet, even if we don't recognize
;              the apid. Negative if no meaningful length can be
;              determined. Actual packet length including header is 
;              length+7
;    pkt_idx=- Index into pkt_def of the packet definition to
;              use with this packet, or -1 if the packet is not
;              valid or recognized.
;  return
;    true if packet is valid, false if not. Returns 
;    true even if the packet is unrecognized.
;Definitions:
;  A packet is Valid if it has a valid CCSDS primary header. A packet is 
;  Recognized if it has an APID which matches one of the entries in the
;  packet definition table, and it decomutates properly. If the packet
;  has a recognized APID but does not decomutate properly, for instance
;  the length in the CCSDS primary header does not match the length in
;  the packet definition table, then the packet is neither valid nor
;  recognized.
function check_ccsds,data,pkt_def,header=header,length=length,pkt_idx=pkt_idx,need_sec=need_sec,need_grp=need_grp
  t_u8=1
  t_u16=12
  length=-1 ;If we return early, we are totally out of sync, don't know how 
            ;many bytes to read to get into sync
  pkt_idx=-1
  if n_elements(data) lt 6 then return,0
  header=parse_pkt(data,0,pkt_def[0])
  if header.ver ne 0 then return,0
  if header.type ne 0 then return,0
  if n_elements(need_sec) gt 0 then if header.scnd_hdr ne need_sec then return, 0
  if n_elements(need_grp) gt 0 then if header.grp_flg ne need_grp then return, 0
  apid=header.apid and '7ff'xu
  length=header.data_len
  w=where(apid eq pkt_def[*].apid,count)
  if count eq 1 then begin
    if pkt_def[w].length ne 0 and length ne pkt_def[w].length then begin
      message,/info,string(format='(%"Packet length doesn''t match (apid %03x, expected %d, was %d)")',apid,pkt_def[w].length,length)
      return,0
    end
    pkt_idx=w
  end
  return,1
end

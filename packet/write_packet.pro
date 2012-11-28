pro stuff_array,result,field,value
  min_len_result=field.pos+n_elements(value)
  result_end=min_len_result-1
  if n_elements(result) lt min_len_result then result=[result,bytarr(min_len_result-n_elements(result))]
  result[field.pos:result_end] or= value
end

pro stuff_field,result,field,value
  if field.length gt 0 then value=value and (2UL^(field.length)-1)
  if field.shift gt 0 then value=ishft(value,field.shift)
  value=swap_endian(/swap_if_little,fix(type=field.type,value)) ;coerce to correct type (in case ruined by length or shift) then swap endian
  value=byte(value,0,type_length(field.type))
  stuff_array,result,field,value
end
;
;Given a structure in the form that would be generated by read_raw_packet, and a packet definition,
;generate an array of bytes containing the packet.
;input
;  pkt_def - packet definition, must be scalar
;  str     - data structure, must be scalar
;  /reset_seq - optional: set to reset the sequence counters to zero
function write_packet,pkt_def,str_,rest,reset_seq=reset_seq
  ;Read CCSDS header
  common write_packet_seq_static,seq
  if n_elements(seq) eq 0 or keyword_set(reset_seq) then begin
    seq=uintarr(2048)
  end
  str=str_
  str.ver=0
  str.type=0
  str.apid=pkt_def.apid
  str.ssc=seq[str.apid]
  fields=*pkt_def.fields
  pt=tag_names(pkt_def)
  w=where(pt eq 'ENUM',count)
  if count gt 0 then enum=*pkt_def.enum
  ft=strupcase(fields.name)
  st=tag_names(str)
  result=bytarr(6) ;Guaranteed to have at least the CCSDS header
  for i=0,n_elements(fields)-1 do begin
    field=fields[i]
    if ft[i] eq 'DATA_LEN' then continue
    if field.length lt 0 then begin
      value=swap_endian(rest)
      if size(value,/type) ne field.type then message,"Type mismatch" ;check type
      value=byte(value,0,n_elements(value)*type_length(field.type))
      stuff_array,result,field,value
    end else begin
      w=where(ft[i] eq st,count)
      if n_elements(count) eq 1 then begin
        value=str.(w)
        if n_elements(enum) gt 0 then begin
          w2=where(ft[i] eq enum.name,count)
          if count gt 0 then begin
            map=*enum[w2].map
            w3=where(map.tag eq value,count)
            if count gt 0 then value=fix(map[w3].value,type=field.type)
          end
        end
;        value=fix(value,type=field.type) ;coerce type
        if size(value,/type) ne field.type then message,"Type mismatch" ;check type
        stuff_field,result,field,value
      end
    end
  end  
  field=fields[where(ft eq 'DATA_LEN')]
  stuff_field,result,field,n_elements(result)-7
  seq[str.apid]++
  return,result
end

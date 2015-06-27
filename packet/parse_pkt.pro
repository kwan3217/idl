;Decomutate a byte array. This is intended to get
;fields out of a raw CCSDS packet.
;
;input 
;  data - 1D array of bytes, containing 1 or more
;         packets, perhaps with garbage or fill data
;         between them
;  idx  - 1D array of indices of the first byte of each
;         packet in the data array
;  pkt_desc - scalar packet description to use to decomutate 
;             each packet, in the format described below. 
;             Note that this means that you only can 
;             decomutate one kind of packet per call to 
;             parse_pkt.
;return
;  An array of structures, one element for each element of 
;  idx, with a format as described in the packet description
;  and with the data converted from raw bits to IDL primitives
;  int, float, double, etc.
;
;Packet description
;  A packet description is an anonymous structure with the 
;  following format:
;  
;  name -   name of the packet, for human use only. string
;  apid -   Application Process Identifier, as in the CCSDS 
;           packet. Used by other processes to decide if a 
;           packet matches a description. 16-bit integer 
;           but apid can only be 11 bits, so it's always positive.
;  length - Length of the packet, matching the encoding in the
;           CCSDS packet, actual length in bytes minus 7, so 
;           a packet with a length of 128 bytes including the CCSDS
;           primary header will have a value of 121 here. 16 bit
;           integer, so needs to be unsigned if packet length
;           is greater than about 32kB.
;  fields - Pointer to an array of structures. It's a pointer so that
;           multiple packet definitions with different numbers of 
;           fields can be put in an array with each other.
;  *fields.name -   field name of this field. String, must be 
;                   usable as an IDL identifier and different
;                   from all other fields in the packet
;  *fields.type -   type of the field. Types come from the IDL size(/type)
;                   table. Only numeric types are supported.
;                    1 - unsigned 8-bit integer
;                   12 - unsigned 16-bit integer
;                   13 - unsigned 32-bit integer
;                    4 - IEEE754 formatted single precision
;                        32-bit floating point number
;                    5 - IEEE754 formatted double precision
;                        64-bit floating point number
;  *fields.pos -    byte index of the first bit of the field, relative
;                   to the beginning of the packet. 
;  *fields.shift -  Number of bits to shift right
;  *fields.length - Number of bits in the value. Zero is the same
;                   as the natural length implied by fields.type
;Notes
;  Byte stream is assumed to be big-endian, meaning that the
;  most significant byte of a multi-byte entity is sent first
;  and has the lowest array index, followed by the next-most 
;  significant, and so on in order to the least, which will
;  have the highest array index. This program converts fields
;  from this big-endian order to whichever order is appropriate
;  for the host system. Individual bits in a byte are also
;  numbered in a big-endian manner. The most significant bit
;  is numbered 0, and then the bits follow in order to bit
;  7, the least-significant.
;
;  Fields smaller than the IDL primitive types can be used. For 
;  instance, the APID field of a CCSDS packet is an 11-bit 
;  quantity with its most significant bit at bit 5 of byte 0.
;  In this case, its type is unsigned 16 bit, because it
;  crosses a byte boundary. It is then shifted to the right
;  zero bits and masked to 11-bit length. If another field
;  started at bit 4 of byte 17 and extended for 7 bits, it
;  would also be a 16-bit unsigned number, even though the 
;  value is less than 8 bits. This is because the value crosses
;  a byte boundary. So it would have a type of 12 (U16), an
;  index of 17, a shift of 5 (16 bits-7 length-4 start), and
;  a length of 7.
;
;  If you have a byte array with many kinds of packets in it,
;  and you want to get them all out, get them out one packet
;  type at a time. First identify where all packets with
;  apid A start, then call parse_pkt with the byte array,
;  apid A index, and apid A packet description. Do the same
;  with B, C, etc until all packets are gotten.
;  
function parse_pkt,data,idx,pkt_desc
  result=create_struct('name',pkt_desc.name)
  t=tag_names(pkt_desc)
  junk=where(t eq 'ENUM',count)
  if count gt 0 && ptr_valid(pkt_desc.enum) then enum=*pkt_desc.enum
  for i=0,n_elements(*pkt_desc.fields)-1 do begin
    field=(*pkt_desc.fields)[i]
    ;The following two lines properly leave shift and length undefined if needed
    if field.shift ne 0 then shift=field.shift else if n_elements(shift) gt 0 then junk=temporary(shift)
    if field.length ne 0 then length=field.length else if n_elements(length) gt 0 then junk=temporary(length)
    if field.rep ne 0 then rep=field.rep else if n_elements(rep) gt 0 then junk=temporary(rep)
    value=get_data(data,idx+field.pos,field.type,shift,length,rep)
    if n_elements(enum) gt 0 then begin
      w=where(strupcase(enum.name) eq strupcase(field.name),count)
      if count gt 0 then begin
        map=*(enum[w].map)
        w=where(map.value eq value,count)
        if count gt 0 then value=map[w].tag
      end
    end
    if n_elements(result) eq 0 then begin
      result=create_struct(field.name,value)
    end else begin
      result=create_struct(result,field.name,value)
    end
  end
  ;Turn it from a structure of arrays to an array of structures
  if n_elements(idx) gt 1 then result=reverse_array_struct(result)
  if ptr_valid(pkt_desc.decomp) then if n_elements(*pkt_desc.decomp) ge 1 then begin
    ptr=0
    for i=0,n_elements(result)-1 do begin
      packet=result[i]
      for j=0,n_elements(*pkt_desc.decomp)-1 do begin
        decomp=(*pkt_desc.decomp)[j]
        if n_elements(uncomp) gt 0 then junk=temporary(uncomp) 
        if decomp.samples gt 0 then begin
          for k=0,(decomp.samples/decomp.blocksize)-1 do begin
            this_decomp=decompress(packet.comp_data,ptr,decomp.blocksize)
            if n_elements(uncomp) eq 0 then uncomp=this_decomp else uncomp=[uncomp,this_decomp]
          end
        end else begin
          edac_ok=1
          while edac_ok && ptr/8 lt n_elements(packet.comp_data) do begin
           ; this_decomp=decompress(packet.comp_data,ptr,decomp.blocksize,edac_ok=edac_ok,nd=nd)
            if nd eq 1 then edac_ok=0
            if edac_ok then if n_elements(uncomp) eq 0 then uncomp=this_decomp else uncomp=[uncomp,this_decomp]
          end 
        end
        packet=create_struct(packet,decomp.name,uncomp)
      end
      if n_elements(new_result) eq 0 then new_result=packet else new_result=[new_result,packet]
    end
    result=temporary(new_result)
  end
  return,result
end

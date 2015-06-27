pro simple_packet
  ;These don't have to, but they do match the IDL size(/type) constants
  ;just because it might be convenient someday.
  t_u8=1
  t_i16=2
  t_i32=3
  t_u16=12
  t_u32=13
  t_float=4
  t_double=5

  ;A byte stream with data for two identical-structured packets. 
  ;This packet has a 32-bit unsigned int, followed by a bitfield, 
  ;followed by a double precision floating point.

  data=byte([  0,  0,100,  0, $;25600 unsigned int32
             195,             $; Bitfield byte, 4-bit b=12, 2-bit c=0, 2-bit d=3
             192,  9, 33,251, 84, 68, 45, 24, $ ;double precision -pi
               0,  0,  0,  0, $;  0 unsigned int32
              64,             $; Bitfield byte, 4-bit b=3, 2-bit c=0, 2-bit d=0
              64,  5,191, 10,139, 20, 87,105])   ;double precision e

;  Packet definition for this packet

  ; 1st byte
  ; AAAAAAAA AAAAAAAA AAAAAAAA AAAAAAAA BBBBCCDD EEEEEEEE... (8 bytes total of Es)
  ; 76543210 bit numbering (bit 7 is most significant bit)
  simple1_desc={name:"Simple1",apid:0U,length:0U,fields:ptr_new([ $
                {name:"a"              ,type:t_u32   ,pos:  0,shift:0,length: 0}, $
                {name:"b"              ,type:t_u8    ,pos:  4,shift:4,length: 4}, $
                {name:"c"              ,type:t_u8    ,pos:  4,shift:2,length: 2}, $
                {name:"d"              ,type:t_u8    ,pos:  4,shift:0,length: 2}, $
                {name:"e"              ,type:t_double,pos:  5,shift:0,length: 0}  $
               ])}

  ;Use the packet definition to read the packet
  pkt=parse_pkt(data,[0,13],simple1_desc)
  ptr_free,simple1_desc.fields

  help,pkt
  help,pkt[0],/str
  help,pkt[1],/str

  ;Another simple packet demonstrating signed and unsigned numbers
  simple2_desc={name:"Simple2",apid:0U,length:0U,fields:ptr_new([ $
                {name:"a"              ,type:t_u16   ,pos:  0,shift:0,length: 0}, $
                {name:"b"              ,type:t_i16   ,pos:  2,shift:0,length: 0}  $
               ])}

  data2=byte([200,0,200,0,123,45,67,89])
  
  pkt2=parse_pkt(data2,[0,4],simple2_desc)
  ptr_free,simple2_desc.fields

  help,pkt2
  help,pkt2[0],/str
  help,pkt2[1],/str

  ;Try out struct_to_pkt_def
  
  simple3_desc=struct_to_pkt_def({a:0u,b:0})
  pkt3=parse_pkt(data2,[0,4],simple3_desc)
  ptr_free,simple3_desc.fields
  
  help,pkt3
  help,pkt3[0],/str
  help,pkt3[1],/str

  

end

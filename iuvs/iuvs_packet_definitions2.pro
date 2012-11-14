function iuvs_packet_definitions2
  ;These don't have to, but they do match the IDL size(/type) constants
  ;just because it might be convenient someday.
  t_u8=1
  t_i16=2
  t_i32=3
  t_u16=12
  t_u32=13
  t_float=4
  t_double=5
  REST=-2
  header_pkt_desc={name:"CCSDS Header",apid:0U,length:6U,fields:ptr_new([ $
              {name:'ver'                 ,type:t_u8    ,pos:  0,shift:5,length: 3,rep:0}, $
              {name:'type'                ,type:t_u8    ,pos:  0,shift:4,length: 1,rep:0}, $
              {name:'scnd_hdr'            ,type:t_u8    ,pos:  0,shift:3,length: 1,rep:0}, $
              {name:'apid'                ,type:t_u16   ,pos:  0,shift:0,length:11,rep:0}, $
              {name:'grp_flg'             ,type:t_u8    ,pos:  2,shift:6,length: 2,rep:0}, $
              {name:'ssc'                 ,type:t_u16   ,pos:  2,shift:0,length:14,rep:0}, $
              {name:'data_len'            ,type:t_u16   ,pos:  4,shift:0,length: 0,rep:0}  $
             ]),decomp:ptr_new(),enum:ptr_new()}
             
  sec_ter_pkt_desc={name:"Secondary/Tertiary Header",apid:0U,length:8U,fields:ptr_new([ $             
                {name:'sc_clk_coarse'       ,type:t_u32   ,pos:  6,shift:0,length: 0,rep:0}, $
                {name:'sc_clk_fine'         ,type:t_u16   ,pos: 10,shift:0,length: 0,rep:0}, $ 
                {name:'dfb_tertiary',       type:t_u16   ,pos: 12,shift:0,length: 0,rep:0}   $
             ]),decomp:ptr_new(),enum:ptr_new()}

a=[{name:'LENGTH',type:t_U32,pos:17,shift:0,length:0,rep:0}]
a=[a,{name:'IMAGE_NUMBER',type:t_U16,pos:21,shift:0,length:0,rep:0}]
a=[a,{name:'AVERAGE',type:t_U16,pos:23,shift:0,length:0,rep:0}]
a=[a,{name:'CHECKSUM',type:t_U16,pos:25,shift:0,length:0,rep:0}]
a=[a,{name:'START_TIME',type:t_U32,pos:27,shift:0,length:0,rep:0}]
a=[a,{name:'START_TIME__SUB',type:t_U16,pos:31,shift:0,length:0,rep:0}]
a=[a,{name:'CADENCE',type:t_U16,pos:33,shift:0,length:0,rep:0}]
a=[a,{name:'NUMBER',type:t_U16,pos:35,shift:0,length:0,rep:0}]
a=[a,{name:'INT_TIME',type:t_U16,pos:37,shift:0,length:0,rep:0}]
a=[a,{name:'MIRROR_POS',type:t_U16,pos:39,shift:0,length:0,rep:0}]
a=[a,{name:'STEP_NUM',type:t_U16,pos:41,shift:0,length:0,rep:0}]
a=[a,{name:'STEP_SIZE',type:t_I16,pos:43,shift:0,length:0,rep:0}]
a=[a,{name:'STEP_INT',type:t_U8,pos:45,shift:0,length:0,rep:0}]
a=[a,{name:'BIN_SHIFT',type:t_U8,pos:46,shift:0,length:0,rep:0}]
a=[a,{name:'OBS_ID',type:t_U16,pos:47,shift:0,length:0,rep:0}]
a=[a,{name:'FUV_BAD_PIXEL_MASK',type:t_U8,pos:49,shift:0,length:1,rep:0}]
a=[a,{name:'MUV_BAD_PIXEL_MASK',type:t_U8,pos:49,shift:1,length:1,rep:0}]
a=[a,{name:'DATA_COMPRESSION',type:t_U8,pos:49,shift:2,length:1,rep:0}]
a=[a,{name:'TEST_PATTERN',type:t_U8,pos:49,shift:3,length:1,rep:0}]
a=[a,{name:'ON_CHIP_WINDOWING',type:t_U8,pos:49,shift:4,length:1,rep:0}]
a=[a,{name:'BIN_TYPE',type:t_U8,pos:49,shift:5,length:1,rep:0}]
a=[a,{name:'SCAN_MODE',type:t_U8,pos:49,shift:6,length:2,rep:0}]
a=[a,{name:'MODE',type:t_U8,pos:50,shift:1,length:2,rep:0}]
a=[a,{name:'TIME_FLAG',type:t_U8,pos:50,shift:7,length:1,rep:0}]
a=[a,{name:'SHUTTER_ON',type:t_U16,pos:51,shift:0,length:0,rep:0}]
a=[a,{name:'SHUTTER_OFF',type:t_U16,pos:53,shift:0,length:0,rep:0}]
a=[a,{name:'SHUTTER_NUM',type:t_U8,pos:55,shift:0,length:0,rep:0}]
a=[a,{name:'SET_TOTAL',type:t_U16,pos:56,shift:0,length:0,rep:0}]
a=[a,{name:'BIN_X_ROW',type:t_U8,pos:58,shift:0,length:0,rep:0}]
a=[a,{name:'BIN_Y_ROW',type:t_U8,pos:59,shift:0,length:0,rep:0}]
a=[a,{name:'DET_TEMP',type:t_U16,pos:60,shift:0,length:0,rep:0}]
a=[a,{name:'CASE_TEMP',type:t_U16,pos:62,shift:0,length:0,rep:0}]
a=[a,{name:'MCP_GAIN',type:t_U16,pos:64,shift:0,length:0,rep:0}]
a=[a,{name:'SCI_SEG_TOTAL',type:t_U16,pos:66,shift:0,length:0,rep:0}]
a=[a,{name:'SCI_SEG_LENGTH',type:t_U16,pos:68,shift:0,length:0,rep:0}]
a=[a,{name:'SCI_SEG_NUM',type:t_U16,pos:70,shift:0,length:0,rep:0}]
a=[a,{name:'SCI_IMG_DATA',type:t_U16,pos:72,shift:0,length:REST,rep:0}]
;These match the field names produced by the old method, through Beth's get_tlm program, the .txt headers, and so on             
  img_pkt_desc={name:"Image",apid:'7'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'sci_pkt_cksum',       type:t_u8   ,pos: 15,shift:0,length: 0,rep:0}, $
                {name:'sci_err_flags',       type:t_u8   ,pos: 16,shift:0,length: 0,rep:0}, $
                {name:'xuv',  type:t_u8   ,pos: 16,shift:0,length: 1,rep:0}, $
              a]), $
              decomp:ptr_new(), $
              enum:ptr_new([ $
                {name:'BIN_TYPE',map:ptr_new([{value:0,tag:'LINEAR'},{value:1,tag:'NON LINEAR'}])}, $
                {name:'XUV',map:ptr_new([{value:0,tag:'FUV'},{value:1,tag:'MUV'}])}, $
                {name:'TEST_PATTERN',map:ptr_new([{value:0,tag:12},{value:1,tag:16}])}, $
                {name:'MODE',map:ptr_new([{value:0,tag:'UNKNOWN'},{value:1,tag:'NOMINAL'},{value:2,tag:'RISING'},{value:3,tag:'SETTING'}])}, $
                {name:'TIME_FLAG',map:ptr_new([{value:0,tag:'Freewheel'},{value:1,tag:'Synced'}])}, $
                {name:'SCAN_MODE',map:ptr_new([{value:0,tag:'TEST'},{value:1,tag:'BLACK'},{value:2,tag:'RAW'},{value:3,tag:'CDS'}])} $
              ])}

  packets=[header_pkt_desc, $
           img_pkt_desc]
           
  return,packets
end

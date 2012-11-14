function iuvs_packet_definitions
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
             ]),decomp:ptr_new()}
             
  sec_ter_pkt_desc={name:"Secondary/Tertiary Header",apid:0U,length:8U,fields:ptr_new([ $             
                {name:'sc_clk_coarse'       ,type:t_u32   ,pos:  6,shift:0,length: 0,rep:0}, $
                {name:'sc_clk_fine'         ,type:t_u16   ,pos: 10,shift:0,length: 0,rep:0}, $ 
                {name:'dfb_tertiary',       type:t_u16   ,pos: 12,shift:0,length: 0,rep:0}   $
             ]),decomp:ptr_new()}
             
  img_pkt_desc={name:"Image",apid:'7'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'sci_pkt_cksum',       type:t_u8   ,pos: 15,shift:0,length: 0,rep:0}, $
                {name:'sci_err_flags',       type:t_u8   ,pos: 16,shift:0,length: 0,rep:0}, $
                {name:'sci_img_det_is_muv',  type:t_u8   ,pos: 16,shift:0,length: 1,rep:0}, $
{name:'SCI_IMG_LENGTH',type:t_U32,pos:17,shift:0,length:0,rep:0}, $
{name:'SCI_IMG_CT',type:t_U16,pos:21,shift:0,length:0,rep:0}, $
{name:'SCI_AVERAGE',type:t_U16,pos:23,shift:0,length:0,rep:0}, $
{name:'SCI_CHECKSUM',type:t_U16,pos:25,shift:0,length:0,rep:0}, $
{name:'SCI_TM',type:t_U32,pos:27,shift:0,length:0,rep:0}, $
{name:'SCI_TM_SS',type:t_U16,pos:31,shift:0,length:0,rep:0}, $
{name:'SCI_IMG_CADENCE',type:t_U16,pos:33,shift:0,length:0,rep:0}, $
{name:'SCI_IMG_NUM',type:t_U16,pos:35,shift:0,length:0,rep:0}, $
{name:'SCI_IMG_INT_TM',type:t_U16,pos:37,shift:0,length:0,rep:0}, $
{name:'SCI_MIRROR_START',type:t_U16,pos:39,shift:0,length:0,rep:0}, $
{name:'SCI_MIRROR_NUM',type:t_U16,pos:41,shift:0,length:0,rep:0}, $
{name:'SCI_MIRROR_SIZE',type:t_I16,pos:43,shift:0,length:0,rep:0}, $
{name:'SCI_MIRROR_INT',type:t_U8,pos:45,shift:0,length:0,rep:0}, $
{name:'SCI_IMG_OFFSET',type:t_U8,pos:46,shift:0,length:0,rep:0}, $
{name:'SCI_OBS_ID',type:t_U16,pos:47,shift:0,length:0,rep:0}, $
{name:'SCI_SHUT_ON',type:t_U16,pos:51,shift:0,length:0,rep:0}, $
{name:'SCI_SHUT_OFF',type:t_U16,pos:53,shift:0,length:0,rep:0}, $
{name:'SCI_SHUT_NUM',type:t_U8,pos:55,shift:0,length:0,rep:0}, $
{name:'SCI_IMG_NUM_ACT',type:t_U16,pos:56,shift:0,length:0,rep:0}, $
{name:'SCI_BIN_SPEC_ROW',type:t_U8,pos:58,shift:0,length:0,rep:0}, $
{name:'SCI_BIN_SPAT_ROW',type:t_U8,pos:59,shift:0,length:0,rep:0}, $
{name:'SCI_DET_TMP',type:t_U16,pos:60,shift:0,length:0,rep:0}, $
{name:'SCI_TMP',type:t_U16,pos:62,shift:0,length:0,rep:0}, $
{name:'SCI_MCP_CMD',type:t_U16,pos:64,shift:0,length:0,rep:0}, $
{name:'SCI_SEG_TOTAL',type:t_U16,pos:66,shift:0,length:0,rep:0}, $
{name:'SCI_SEG_LENGTH',type:t_U16,pos:68,shift:0,length:0,rep:0}, $
{name:'SCI_SEG_NUM',type:t_U16,pos:70,shift:0,length:0,rep:0}, $
{name:'SCI_IMG_DATA',type:t_U16,pos:72,shift:0,length:REST,rep:0}  $
              ]),decomp:ptr_new()}

  packets=[header_pkt_desc, $
           img_pkt_desc]
           
  return,packets
end

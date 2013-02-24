function rkto_packet_defs
  ;These don't have to, but they do match the IDL size(/type) constants
  ;just because it might be convenient someday.
  t_u8=1
  t_i16=2
  t_i32=3
  t_u16=12
  t_u32=13
  t_str=7
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
             
  sec_pkt_desc={name:"SecondaryHeader",apid:0U,length:4U,fields:ptr_new([ $             
                {name:'TC'       ,type:t_u32   ,pos:  6,shift:0,length: 0,rep:0} $
             ]),decomp:ptr_new(),enum:ptr_new()}


  adxl_desc={name:"ADXL345 raw readout",apid:'1'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_pkt_desc.fields), $
                {name:'x',       type:t_i16   ,pos: 8,shift:0,length: 0,rep:0}, $
                {name:'y',       type:t_i16   ,pos:10,shift:0,length: 0,rep:0}, $
                {name:'z',       type:t_i16   ,pos:12,shift:0,length: 0,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}

  bmpcal_desc={name:"BMP180 Calibration Constants",apid:'2'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                {name:'ac1',       type:t_i16   ,pos: 6,shift:0,length: 0,rep:0}, $
                {name:'ac2',       type:t_i16   ,pos: 8,shift:0,length: 0,rep:0}, $
                {name:'ac3',       type:t_i16   ,pos:10,shift:0,length: 0,rep:0}, $
                {name:'ac4',       type:t_u16   ,pos:12,shift:0,length: 0,rep:0}, $
                {name:'ac5',       type:t_u16   ,pos:14,shift:0,length: 0,rep:0}, $
                {name:'ac6',       type:t_u16   ,pos:16,shift:0,length: 0,rep:0}, $
                {name:'b1',        type:t_i16   ,pos:18,shift:0,length: 0,rep:0}, $
                {name:'b2',        type:t_i16   ,pos:20,shift:0,length: 0,rep:0}, $
                {name:'mb',        type:t_i16   ,pos:22,shift:0,length: 0,rep:0}, $
                {name:'mc',        type:t_i16   ,pos:24,shift:0,length: 0,rep:0}, $
                {name:'md',        type:t_i16   ,pos:26,shift:0,length: 0,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}

  dump_desc={name:"Source dump",apid:'3'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                {name:'address',       type:t_u16   ,pos: 6,shift:0,length: 0,rep:0}, $
                {name:'data',          type:t_u8    ,pos: 8,shift:0,length:REST,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}

  hmc_desc={name:"HMC5883L raw readout",apid:'4'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_pkt_desc.fields), $
                {name:'x',       type:t_i16   ,pos:10,shift:0,length: 0,rep:0}, $
                {name:'y',       type:t_i16   ,pos:12,shift:0,length: 0,rep:0}, $
                {name:'z',       type:t_i16   ,pos:14,shift:0,length: 0,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}

  L3G_desc={name:"L3G4200D raw readout",apid:'5'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_pkt_desc.fields), $
                {name:'x',       type:t_i16   ,pos:10,shift:0,length: 0,rep:0}, $
                {name:'y',       type:t_i16   ,pos:12,shift:0,length: 0,rep:0}, $
                {name:'z',       type:t_i16   ,pos:14,shift:0,length: 0,rep:0}, $
                {name:'t',       type:t_i16   ,pos:16,shift:0,length: 0,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}

  MPU_desc={name:"MPU60x0 raw readout",apid:'6'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_pkt_desc.fields), $
                {name:'ax',       type:t_i16   ,pos:10,shift:0,length: 0,rep:0}, $
                {name:'ay',       type:t_i16   ,pos:12,shift:0,length: 0,rep:0}, $
                {name:'az',       type:t_i16   ,pos:14,shift:0,length: 0,rep:0}, $
                {name:'gx',       type:t_i16   ,pos:16,shift:0,length: 0,rep:0}, $
                {name:'gy',       type:t_i16   ,pos:18,shift:0,length: 0,rep:0}, $
                {name:'gz',       type:t_i16   ,pos:20,shift:0,length: 0,rep:0}, $
                {name:'t',        type:t_i16   ,pos:22,shift:0,length: 0,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}

  bmp_desc={name:"BMP180 raw readout",apid:'7'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_pkt_desc.fields), $
                {name:'T',       type:t_i16   ,pos:10,shift:0,length: 0,rep:0}, $
                {name:'P',       type:t_i32   ,pos:12,shift:0,length: 0,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}

  sd_desc={name:"SD Timing",apid:'8'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_pkt_desc.fields), $
                {name:'TC1',     type:t_u32   ,pos:10,shift:0,length: 0,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}
  bmp2_desc={name:"BMP180 raw and processed readout",apid:'a'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_pkt_desc.fields), $
                {name:'Traw',       type:t_i16   ,pos:10,shift:0,length: 0,rep:0}, $
                {name:'Praw',       type:t_i32   ,pos:12,shift:0,length: 0,rep:0}, $
                {name:'Tphy',       type:t_i16   ,pos:16,shift:0,length: 0,rep:0}, $
                {name:'Pphy',       type:t_i32   ,pos:18,shift:0,length: 0,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}
  ad377_desc={name:"AD377 raw readout",apid:'b'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_pkt_desc.fields), $
                {name:'data',       type:t_i16   ,pos:10,shift:0,length:REST,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}
  ver_desc={name:"Version",apid:'c'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                {name:'HW_TYPE',       type:t_u32  ,pos: 6,shift:0,length: 0,rep:0}, $
                {name:'HW_SERIAL',     type:t_u32  ,pos:10,shift:0,length: 0,rep:0}, $
                {name:'MAMCR',         type:t_u8   ,pos:14,shift:0,length: 0,rep:0}, $
                {name:'MAMTIM',        type:t_u8   ,pos:15,shift:0,length: 0,rep:0}, $
                {name:'PLL0STAT',      type:t_u16  ,pos:16,shift:0,length: 0,rep:0}, $
                {name:'VPBDIV',        type:t_u8   ,pos:18,shift:0,length: 0,rep:0}, $
                {name:'FOSC',          type:t_u32  ,pos:19,shift:0,length: 0,rep:0}, $
                {name:'CCLK',          type:t_u32  ,pos:23,shift:0,length: 0,rep:0}, $
                {name:'PCLK',          type:t_u32  ,pos:27,shift:0,length: 0,rep:0}, $
                {name:'PREINT',        type:t_u32  ,pos:31,shift:0,length: 0,rep:0}, $
                {name:'PREFRAC',       type:t_u32  ,pos:35,shift:0,length: 0,rep:0}, $
                {name:'CCR',           type:t_u8   ,pos:39,shift:0,length: 0,rep:0}, $
                {name:'VERSION',       type:t_str  ,pos:40,shift:0,length:REST,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}
  ad7991_desc={name:"AD7991 configuration",apid:'d'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                {name:'Address',       type:t_u8   ,pos:6,shift:0,length: 0,rep:0}, $
                {name:'channel_mask',       type:t_u8   ,pos:7,shift:0,length: 0,rep:0}, $
                {name:'n_channels',       type:t_u8   ,pos:8,shift:0,length: 0,rep:0}, $
                {name:'worked',       type:t_u8   ,pos:9,shift:0,length: 0,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}
  ver_desc={name:"Version",apid:'c'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                {name:'HW_TYPE',       type:t_u32  ,pos: 6,shift:0,length: 0,rep:0}, $
                {name:'HW_SERIAL',     type:t_u32  ,pos:10,shift:0,length: 0,rep:0}, $
                {name:'MAMCR',         type:t_u8   ,pos:14,shift:0,length: 0,rep:0}, $
                {name:'MAMTIM',        type:t_u8   ,pos:15,shift:0,length: 0,rep:0}, $
                {name:'PLL0STAT',      type:t_u16  ,pos:16,shift:0,length: 0,rep:0}, $
                {name:'VPBDIV',        type:t_u8   ,pos:18,shift:0,length: 0,rep:0}, $
                {name:'FOSC',          type:t_u32  ,pos:19,shift:0,length: 0,rep:0}, $
                {name:'CCLK',          type:t_u32  ,pos:23,shift:0,length: 0,rep:0}, $
                {name:'PCLK',          type:t_u32  ,pos:27,shift:0,length: 0,rep:0}, $
                {name:'PREINT',        type:t_u32  ,pos:31,shift:0,length: 0,rep:0}, $
                {name:'PREFRAC',       type:t_u32  ,pos:35,shift:0,length: 0,rep:0}, $
                {name:'CCR',           type:t_u8   ,pos:39,shift:0,length: 0,rep:0}, $
                {name:'VERSION',       type:t_str  ,pos:40,shift:0,length:REST,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}
  hmc5883_desc={name:"HMC5883 configuration",apid:'e'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                {name:'MA',       type:t_u8   ,pos:6,shift:5,length: 2,rep:0}, $
                {name:'DO',       type:t_u8   ,pos:6,shift:2,length: 3,rep:0}, $
                {name:'MS',       type:t_u8   ,pos:6,shift:0,length: 2,rep:0}, $
                {name:'GN',       type:t_u8   ,pos:7,shift:5,length: 3,rep:0}, $
                {name:'MD',       type:t_u8   ,pos:8,shift:0,length: 2,rep:0}, $
                {name:'LOCK',     type:t_u8   ,pos:9,shift:1,length: 1,rep:0}, $
                {name:'RDY',      type:t_u8   ,pos:9,shift:0,length: 1,rep:0}, $
                {name:'ID',      type:t_str   ,pos:10,shift:0,length: 0,rep:3}]), $
              decomp:ptr_new(), enum:ptr_new()}
  mpu60x0_cfg={name:"MPU60x0 configuration",apid:'f'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                {name:'ADDRESS',       type:t_u8   ,pos: 6,shift:0,length: 0,rep:0}, $
                {name:'XA_TEST_HI',    type:t_u8   ,pos: 7,shift:5,length: 3,rep:0}, $
                {name:'XG_TEST',       type:t_u8   ,pos: 7,shift:0,length: 5,rep:0}, $
                {name:'YA_TEST_HI',    type:t_u8   ,pos: 8,shift:5,length: 3,rep:0}, $
                {name:'YG_TEST',       type:t_u8   ,pos: 8,shift:0,length: 5,rep:0}, $
                {name:'ZA_TEST_HI',    type:t_u8   ,pos: 9,shift:5,length: 3,rep:0}, $
                {name:'ZG_TEST',       type:t_u8   ,pos: 9,shift:0,length: 5,rep:0}, $
                {name:'XA_TEST_LO',    type:t_u8   ,pos:10,shift:4,length: 2,rep:0}, $
                {name:'YA_TEST_LO',    type:t_u8   ,pos:10,shift:2,length: 2,rep:0}, $
                {name:'ZA_TEST_LO',    type:t_u8   ,pos:10,shift:0,length: 2,rep:0}, $
                {name:'SMPLRT_DIV',    type:t_u8   ,pos:11,shift:0,length: 0,rep:0}, $
                {name:'EXT_SYNC_SET',  type:t_u8   ,pos:12,shift:3,length: 3,rep:0}, $
                {name:'DLPF_CFG',      type:t_u8   ,pos:12,shift:0,length: 3,rep:0}, $
                {name:'XG_ST',         type:t_u8   ,pos:13,shift:7,length: 1,rep:0}, $
                {name:'YG_ST',         type:t_u8   ,pos:13,shift:6,length: 1,rep:0}, $
                {name:'ZG_ST',         type:t_u8   ,pos:13,shift:5,length: 1,rep:0}, $
                {name:'GYRO_FS_SEL',   type:t_u8   ,pos:13,shift:3,length: 2,rep:0}, $
                {name:'XA_ST',         type:t_u8   ,pos:14,shift:7,length: 1,rep:0}, $
                {name:'YA_ST',         type:t_u8   ,pos:14,shift:6,length: 1,rep:0}, $
                {name:'ZA_ST',         type:t_u8   ,pos:14,shift:5,length: 1,rep:0}, $
                {name:'ACC_FS_SEL',    type:t_u8   ,pos:14,shift:3,length: 2,rep:0}, $
                {name:'MOT_THR',       type:t_u8   ,pos:15,shift:0,length: 0,rep:0}, $
                {name:'INT_LEVEL',     type:t_u8   ,pos:16,shift:7,length: 1,rep:0}, $
                {name:'INT_OPEN',      type:t_u8   ,pos:16,shift:6,length: 1,rep:0}, $
                {name:'LATCH_INT_EN',  type:t_u8   ,pos:16,shift:5,length: 1,rep:0}, $
                {name:'INT_RD_CLEAR',  type:t_u8   ,pos:16,shift:4,length: 1,rep:0}, $
                {name:'FSYNC_INT_LVL', type:t_u8   ,pos:16,shift:3,length: 1,rep:0}, $
                {name:'FSYNC_INT_EN',  type:t_u8   ,pos:16,shift:2,length: 1,rep:0}, $
                {name:'I2C_BYP_EN',    type:t_u8   ,pos:16,shift:1,length: 1,rep:0}, $
                {name:'DEV_RESET',     type:t_u8   ,pos:18,shift:7,length: 1,rep:0}, $
                {name:'SLEEP',         type:t_u8   ,pos:18,shift:6,length: 1,rep:0}, $
                {name:'CYCLE',         type:t_u8   ,pos:18,shift:5,length: 1,rep:0}, $
                {name:'TEMP_DIS',      type:t_u8   ,pos:18,shift:3,length: 1,rep:0}, $
                {name:'CLKSEL',        type:t_u8   ,pos:18,shift:0,length: 3,rep:0}, $
                {name:'WHOAMI',        type:t_u8   ,pos:19,shift:0,length: 0,rep:0}]), $
              decomp:ptr_new(), enum:ptr_new()}
  packets=[header_pkt_desc,adxl_desc,bmpcal_desc,dump_desc,hmc_desc,L3G_desc,MPU_desc,bmp_desc,sd_desc,ad377_desc,bmp2_desc,ver_desc,ad7991_desc,hmc5883_desc,mpu60x0_cfg]
          
  return,packets
end

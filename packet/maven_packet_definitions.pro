function maven_packet_definitions,has_msg_header=has_msg_header
  ;These don't have to, but they do match the IDL size(/type) constants
  ;just because it might be convenient someday.
  t_u8=1
  t_i16=2
  t_i32=3
  t_u16=12
  t_u32=13
  t_float=4
  t_double=5
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
             
  atr_pkt_desc={name:"ATR",apid:'51'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'swp',                type:t_u16   ,pos: 14,shift:0,length: 0,rep:128}, $
                {name:'w_bias1',            type:t_u16   ,pos: 270,shift:0,length: 0,rep:0}, $
                {name:'w_guard1',           type:t_u16   ,pos: 272,shift:0,length: 0,rep:0}, $
                {name:'w_stub1',            type:t_u16   ,pos: 274,shift:0,length: 0,rep:0}, $
                ;reserved u16 at 276
                {name:'lp_bias1',            type:t_u16   ,pos: 278,shift:0,length: 0,rep:0}, $
                {name:'lp_guard1',           type:t_u16   ,pos: 280,shift:0,length: 0,rep:0}, $
                {name:'lp_stub1',            type:t_u16   ,pos: 282,shift:0,length: 0,rep:0}, $
                ;reserved u16 at 284
                {name:'w_bias2',            type:t_u16   ,pos: 286,shift:0,length: 0,rep:0}, $
                {name:'w_guard2',           type:t_u16   ,pos: 288,shift:0,length: 0,rep:0}, $
                {name:'w_stub2',            type:t_u16   ,pos: 290,shift:0,length: 0,rep:0}, $
                ;reserved u16 at 292
                {name:'lp_bias2',            type:t_u16   ,pos: 294,shift:0,length: 0,rep:0}, $
                {name:'lp_guard2',           type:t_u16   ,pos: 296,shift:0,length: 0,rep:0}, $
                {name:'lp_stub2',            type:t_u16   ,pos: 298,shift:0,length: 0,rep:0}  $
                ;reserved u16 at 300
              ]),decomp:ptr_new()}

  euv_pkt_desc={name:"EUV",apid:'52'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'comp_data',          type:t_u8    ,pos: 14,shift:0,length: -1,rep:0}  $
              ]),decomp:ptr_new([{name:'therm',samples:16,blocksize:16}, $
                                 {name:'diode_a',samples:16,blocksize:16},  $
                                 {name:'diode_b',samples:16,blocksize:16},  $
                                 {name:'diode_c',samples:16,blocksize:16},  $
                                 {name:'diode_d',samples:16,blocksize:16}   $
                                ])}

  adr_pkt_desc={name:"ADR",apid:'53'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'dyn_offset1',        type:t_i16   ,pos: 14, shift:0,length: 0,rep:0},   $
                {name:'lp_bias1',           type:t_i16   ,pos: 16, shift:0,length: 0,rep:128}, $
                {name:'dyn_offset2',        type:t_i16   ,pos: 272,shift:0,length: 0,rep:0},   $
                {name:'lp_bias2',           type:t_i16   ,pos: 274,shift:0,length: 0,rep:128}, $
                {name:'w_bias1',            type:t_i16   ,pos: 530,shift:0,length: 0,rep:0},   $
                {name:'w_guard1',           type:t_i16   ,pos: 532,shift:0,length: 0,rep:0},   $
                {name:'w_stub1',            type:t_i16   ,pos: 534,shift:0,length: 0,rep:0},   $
                {name:'w_v1_floating_gnd1', type:t_i16   ,pos: 536,shift:0,length: 0,rep:0},   $
                {name:'lp_guard1',          type:t_i16   ,pos: 538,shift:0,length: 0,rep:0},   $
                {name:'lp_stub1',           type:t_i16   ,pos: 540,shift:0,length: 0,rep:0},   $
                {name:'w_bias2',            type:t_i16   ,pos: 542,shift:0,length: 0,rep:0},   $
                {name:'w_guard2',           type:t_i16   ,pos: 544,shift:0,length: 0,rep:0},   $
                {name:'w_stub2',            type:t_i16   ,pos: 546,shift:0,length: 0,rep:0},   $
                {name:'w_v1_floating_gnd2', type:t_i16   ,pos: 548,shift:0,length: 0,rep:0},   $
                {name:'lp_guard2',          type:t_i16   ,pos: 550,shift:0,length: 0,rep:0},   $
                {name:'lp_stub2',           type:t_i16   ,pos: 552,shift:0,length: 0,rep:0}    $
              ]),decomp:ptr_new()}

  hsk_pkt_desc={name:"HSK",apid:'54'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'preamp_temp1',    type:t_i16   ,pos: 14,shift:0,length: 0,rep:0}, $
                {name:'preamp_temp2',    type:t_i16   ,pos: 16,shift:0,length: 0,rep:0}, $
                {name:'beb_temp',        type:t_i16   ,pos: 18,shift:0,length: 0,rep:0}, $
                {name:'P12va',           type:t_i16   ,pos: 20,shift:0,length: 0,rep:0}, $
                {name:'M12va',           type:t_i16   ,pos: 22,shift:0,length: 0,rep:0}, $
                {name:'P5va',            type:t_i16   ,pos: 24,shift:0,length: 0,rep:0}, $
                {name:'M5va',            type:t_i16   ,pos: 26,shift:0,length: 0,rep:0}, $
                {name:'P90va',           type:t_i16   ,pos: 28,shift:0,length: 0,rep:0}, $
                {name:'M90va',           type:t_i16   ,pos: 30,shift:0,length: 0,rep:0}, $
                {name:'cmd_accept',      type:t_u16   ,pos: 32,shift:0,length: 0,rep:0}, $
                {name:'cmd_reject',      type:t_u16   ,pos: 34,shift:0,length: 0,rep:0}, $
                {name:'mem_seu_counter', type:t_u16   ,pos: 36,shift:0,length: 0,rep:0}, $
                {name:'int_stat',        type:t_u16   ,pos: 38,shift:0,length: 0,rep:0}, $
                {name:'chksum',          type:t_u16   ,pos: 40,shift:0,length: 0,rep:0}, $
                {name:'ext_stat',        type:t_u16   ,pos: 42,shift:0,length: 0,rep:0}, $
                {name:'dply1_cnt',       type:t_u16   ,pos: 44,shift:0,length: 0,rep:0}, $
                {name:'dply2_cnt',       type:t_u16   ,pos: 46,shift:0,length: 0,rep:0}  $
              ]),decomp:ptr_new()}

  swp1_pkt_desc={name:"SWP1",apid:'55'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'i_zero1',            type:t_u16   ,pos: 14,shift:0,length: 0,rep:0}, $
                {name:'dyn_offset',         type:t_u16   ,pos: 16,shift:0,length: 0,rep:0}, $
                {name:'comp_data',          type:t_u8    ,pos: 18,shift:0,length: -1,rep:0}  $
              ]),decomp:ptr_new([{name:'I1',samples:128,blocksize:16},{name:'V2',samples:128,blocksize:32}])}

  swp2_pkt_desc={name:"SWP2",apid:'56'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'i_zero2',            type:t_u16   ,pos: 14,shift:0,length: 0,rep:0}, $
                {name:'dyn_offset',         type:t_u16   ,pos: 16,shift:0,length: 0,rep:0}, $
                {name:'comp_data',          type:t_u8    ,pos: 18,shift:0,length: -1,rep:0}  $
              ]),decomp:ptr_new([{name:'I2',samples:128,blocksize:16},{name:'V1',samples:128,blocksize:32}])}

  act_avg_pkt_desc={name:"ACT_AVG",apid:'57'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'comp_data',          type:t_u8    ,pos: 14,shift:0,length: -1,rep:0}  $
              ]),decomp:ptr_new([{name:'V1',    samples:64,blocksize:32}, $
                                 {name:'V2',    samples:64,blocksize:32}, $
                                 {name:'E12_LF',samples:64,blocksize:32}  $
                                ])}

  pas_avg_pkt_desc=act_avg_pkt_desc
  pas_avg_pkt_desc.apid='58'xu
  pas_avg_pkt_desc.name="PAS_AVG"
  pas_avg_pkt_desc.fields=ptr_new(*act_avg_pkt_desc.fields)
                                

  act_lf_pkt_desc={name:"ACT_LF",apid:'59'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'pkt_cnt',            type:t_u16   ,pos: 14,shift:0,length: 0,rep:0}, $
                {name:'bins',               type:t_u8   ,pos: 16,shift:0,length: 0,rep:56} $
              ]),decomp:ptr_new()}

  act_mf_pkt_desc=act_lf_pkt_desc
  act_mf_pkt_desc.apid='5A'xu
  act_mf_pkt_desc.name="ACT_MF"
  act_mf_pkt_desc.fields=ptr_new(*act_lf_pkt_desc.fields)

  act_hf_pkt_desc={name:"ACT_HF",apid:'5B'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'pkt_cnt',            type:t_u16   ,pos: 14,shift:0,length: 0,rep:0}, $
                {name:'bins',               type:t_u8   ,pos: 16,shift:0,length: 0,rep:128} $
              ]),decomp:ptr_new()}

  pas_lf_pkt_desc=act_lf_pkt_desc
  pas_lf_pkt_desc.apid='5C'xu
  pas_lf_pkt_desc.name="PAS_LF"
  pas_lf_pkt_desc.fields=ptr_new(*act_lf_pkt_desc.fields)

  pas_mf_pkt_desc=act_mf_pkt_desc
  pas_mf_pkt_desc.apid='5D'xu
  pas_mf_pkt_desc.name="PAS_MF"
  pas_mf_pkt_desc.fields=ptr_new(*act_mf_pkt_desc.fields)

  pas_hf_pkt_desc=act_hf_pkt_desc
  pas_hf_pkt_desc.apid='5E'xu
  pas_hf_pkt_desc.name="PAS_HF"
  pas_hf_pkt_desc.fields=ptr_new(*act_hf_pkt_desc.fields)

  swp1_uncomp_pkt_desc={name:"SWP1_UNCOMP",apid:'155'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'i_zero1',            type:t_u16   ,pos: 14,shift:0,length: 0,rep:0}, $
                {name:'dyn_offset',         type:t_u16   ,pos: 16,shift:0,length: 0,rep:0}, $
                {name:'I1',                 type:t_i32   ,pos: 18,shift:0,length: 0,rep:128}, $
                {name:'V2',                 type:t_i16   ,pos: 530,shift:0,length: 0,rep:128} $
              ]),decomp:ptr_new()}

  hsbm_lf_pkt_desc={name:"HSBM_LF",apid:'5F'xu,length:0U,fields:ptr_new([ $
                *(header_pkt_desc.fields), $
                *(sec_ter_pkt_desc.fields), $
                {name:'comp_data',          type:t_u8    ,pos: 14,shift:0,length: -1,rep:0}  $
              ]),decomp:ptr_new([{name:'data',    samples:-1,blocksize:32}])}

  hsbm_mf_pkt_desc=hsbm_lf_pkt_desc
  hsbm_mf_pkt_desc.apid='60'xu
  hsbm_mf_pkt_desc.name="HSBM_MF"
  hsbm_mf_pkt_desc.fields=ptr_new(*hsbm_lf_pkt_desc.fields)

  hsbm_hf_pkt_desc=hsbm_lf_pkt_desc
  hsbm_hf_pkt_desc.apid='61'xu
  hsbm_hf_pkt_desc.name="HSBM_HF"
  hsbm_hf_pkt_desc.fields=ptr_new(*hsbm_lf_pkt_desc.fields)

  packets=[header_pkt_desc, $
           atr_pkt_desc, $
           euv_pkt_desc, $
           adr_pkt_desc, $
           hsk_pkt_desc, $
           swp1_pkt_desc, $
           swp2_pkt_desc, $
           act_avg_pkt_desc, $
           pas_avg_pkt_desc, $
           act_lf_pkt_desc, $
           act_mf_pkt_desc, $
           act_hf_pkt_desc, $
           pas_lf_pkt_desc, $
           pas_mf_pkt_desc, $
           pas_hf_pkt_desc, $
           hsbm_lf_pkt_desc, $
           hsbm_mf_pkt_desc, $
           hsbm_hf_pkt_desc, $
           swp1_uncomp_pkt_desc]
           
  if keyword_set(has_msg_header) then begin
    for i=0,n_elements(packets)-1 do begin
      old_ptr=packets[i].fields
      for j=0,n_elements(*old_ptr)-1 do begin
        (*old_ptr)[j].pos+=2
      end
      packets[i].fields=ptr_new([{name:'msg_header',type:t_u16,pos: 0,shift:0,length: 0,rep:0}, *old_ptr])
      ptr_free,old_ptr
      packets[i].length+=2
    end
  end
  return,packets
end

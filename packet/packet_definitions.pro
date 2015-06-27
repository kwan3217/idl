function packet_definitions
  ;These don't have to, but they do match the IDL size(/type) constants
  ;just because it might be convenient someday.
  t_u8=1
  t_u16=12
  t_u32=13
  t_float=4
  t_double=5
  ccsds_header_pkt_desc={name:"CCSDS Header",apid:0U,length:0U,fields:ptr_new([ $
              {name:'ver'                 ,type:t_u8   ,pos:  0,shift:5,length: 3}, $
              {name:'type'                ,type:t_u8   ,pos:  0,shift:4,length: 1}, $
              {name:'scnd_hdr'            ,type:t_u8   ,pos:  0,shift:3,length: 1}, $
              {name:'apid'                ,type:t_u16  ,pos:  0,shift:0,length:11}, $
              {name:'grp_flg'             ,type:t_u8   ,pos:  2,shift:6,length: 2}, $
              {name:'ssc'                 ,type:t_u16  ,pos:  2,shift:0,length:14}, $
              {name:'data_len'            ,type:t_u16  ,pos:  4,shift:0,length: 0}  $
             ])}

  acs_pkt_desc={name:"ACS",apid:129U,length:121U,fields:ptr_new([ $
                *ccsds_header_pkt_desc.fields, $
                {name:'tai_sec'             ,type:t_u32   ,pos:  6,shift:0,length: 0}, $
                {name:'tai_subsec'          ,type:t_u32   ,pos: 10,shift:0,length: 0}, $ 
                {name:'acs_point_flag'      ,type:t_u8    ,pos: 14,shift:0,length: 1}, $
                {name:'dss_sun_present'     ,type:t_u8    ,pos: 15,shift:7,length: 1}, $
                {name:'eclipse_flag'        ,type:t_u8    ,pos: 15,shift:6,length: 1}, $
                {name:'safehld_flag'        ,type:t_u8    ,pos: 15,shift:5,length: 1}, $
                {name:'gt_in_use'           ,type:t_u8    ,pos: 15,shift:3,length: 2}, $
                {name:'acs_mode'            ,type:t_u8    ,pos: 15,shift:0,length: 3}, $
                {name:'tai_targ_quat_sec'   ,type:t_u32   ,pos: 16,shift:0,length: 0}, $ 
                {name:'tai_targ_quat_subsec',type:t_u32   ,pos: 20,shift:0,length: 0}, $ 
                {name:'dss_sun_vec1'        ,type:t_float ,pos: 24,shift:0,length: 0}, $ 
                {name:'dss_sun_vec2'        ,type:t_float ,pos: 28,shift:0,length: 0}, $ 
                {name:'dss_sun_vec3'        ,type:t_float ,pos: 32,shift:0,length: 0}, $ 
                {name:'gt_offset1'          ,type:t_float ,pos: 36,shift:0,length: 0}, $ 
                {name:'gt_offset2'          ,type:t_float ,pos: 40,shift:0,length: 0}, $ 
                {name:'gt_cal_bias1'        ,type:t_float ,pos: 44,shift:0,length: 0}, $ 
                {name:'gt_cal_bias2'        ,type:t_float ,pos: 48,shift:0,length: 0}, $ 
                {name:'srb_bias1'           ,type:t_float ,pos: 52,shift:0,length: 0}, $ 
                {name:'srb_bias2'           ,type:t_float ,pos: 56,shift:0,length: 0}, $ 
                {name:'best_quatx'          ,type:t_float ,pos: 60,shift:0,length: 0}, $ 
                {name:'best_quaty'          ,type:t_float ,pos: 64,shift:0,length: 0}, $ 
                {name:'best_quatz'          ,type:t_float ,pos: 68,shift:0,length: 0}, $ 
                {name:'best_quatw'          ,type:t_float ,pos: 72,shift:0,length: 0}, $ 
                {name:'targ_quatx'          ,type:t_float ,pos: 76,shift:0,length: 0}, $ 
                {name:'targ_quaty'          ,type:t_float ,pos: 80,shift:0,length: 0}, $ 
                {name:'targ_quatz'          ,type:t_float ,pos: 84,shift:0,length: 0}, $ 
                {name:'targ_quatw'          ,type:t_float ,pos: 88,shift:0,length: 0}, $ 
                {name:'utc_best_quat'       ,type:t_double,pos: 96,shift:0,length: 0}  $ 
              ])}

  ephem_pkt_desc={name:"EPHEM",apid:135U,length:489U,fields:ptr_new([ $
                *ccsds_header_pkt_desc.fields, $
                {name:'tai_sec'                 ,type:t_u32   ,pos:  6,shift:0,length: 0}, $
                {name:'tai_subsec'              ,type:t_u32   ,pos: 10,shift:0,length: 0}, $ 
                {name:'ephemdata__spare1'       ,type:t_u16   ,pos: 14,shift:0,length: 0}, $
                {name:'align_ecefftogcif11'     ,type:t_double,pos: 16,shift:0,length: 0}, $
                {name:'align_ecefftogcif12'     ,type:t_double,pos: 24,shift:0,length: 0}, $
                {name:'align_ecefftogcif13'     ,type:t_double,pos: 32,shift:0,length: 0}, $
                {name:'align_ecefftogcif21'     ,type:t_double,pos: 40,shift:0,length: 0}, $
                {name:'align_ecefftogcif22'     ,type:t_double,pos: 48,shift:0,length: 0}, $
                {name:'align_ecefftogcif23'     ,type:t_double,pos: 56,shift:0,length: 0}, $
                {name:'align_ecefftogcif31'     ,type:t_double,pos: 64,shift:0,length: 0}, $
                {name:'align_ecefftogcif32'     ,type:t_double,pos: 72,shift:0,length: 0}, $
                {name:'align_ecefftogcif33'     ,type:t_double,pos: 80,shift:0,length: 0}, $
                {name:'vel_gcif_scwrt_sunx'     ,type:t_double,pos: 88,shift:0,length: 0}, $
                {name:'vel_gcif_scwrt_suny'     ,type:t_double,pos: 96,shift:0,length: 0}, $
                {name:'vel_gcif_scwrt_sunz'     ,type:t_double,pos:104,shift:0,length: 0}, $
                {name:'pos_gcif_scwrtearthx'    ,type:t_double,pos:112,shift:0,length: 0}, $
                {name:'pos_gcif_scwrtearthy'    ,type:t_double,pos:120,shift:0,length: 0}, $
                {name:'pos_gcif_scwrtearthz'    ,type:t_double,pos:128,shift:0,length: 0}, $
                {name:'vel_gcif_scwrtearthx'    ,type:t_double,pos:136,shift:0,length: 0}, $
                {name:'vel_gcif_scwrtearthy'    ,type:t_double,pos:144,shift:0,length: 0}, $
                {name:'vel_gcif_scwrtearthz'    ,type:t_double,pos:152,shift:0,length: 0}, $
                {name:'acc_gcif_scwrtearthx'    ,type:t_double,pos:160,shift:0,length: 0}, $
                {name:'acc_gcif_scwrtearthy'    ,type:t_double,pos:168,shift:0,length: 0}, $
                {name:'acc_gcif_scwrtearthz'    ,type:t_double,pos:176,shift:0,length: 0}, $
                {name:'unit_gcif_scwrtearthx'   ,type:t_double,pos:184,shift:0,length: 0}, $
                {name:'unit_gcif_scwrtearthy'   ,type:t_double,pos:192,shift:0,length: 0}, $
                {name:'unit_gcif_scwrtearthz'   ,type:t_double,pos:200,shift:0,length: 0}, $
                {name:'pos_gcif_sunwrtearthx'   ,type:t_double,pos:208,shift:0,length: 0}, $
                {name:'pos_gcif_sunwrtearthy'   ,type:t_double,pos:216,shift:0,length: 0}, $
                {name:'pos_gcif_sunwrtearthz'   ,type:t_double,pos:224,shift:0,length: 0}, $
                {name:'vel_gcif_sunwrtearthx'   ,type:t_double,pos:232,shift:0,length: 0}, $
                {name:'vel_gcif_sunwrtearthy'   ,type:t_double,pos:240,shift:0,length: 0}, $
                {name:'vel_gcif_sunwrtearthz'   ,type:t_double,pos:248,shift:0,length: 0}, $
                {name:'unit_gcif_sunwrtearthx'  ,type:t_double,pos:256,shift:0,length: 0}, $
                {name:'unit_gcif_sunwrtearthy'  ,type:t_double,pos:264,shift:0,length: 0}, $
                {name:'unit_gcif_sunwrtearthz'  ,type:t_double,pos:272,shift:0,length: 0}, $
                {name:'pos_gcif_moonwrtearthx'  ,type:t_double,pos:280,shift:0,length: 0}, $
                {name:'pos_gcif_moonwrtearthy'  ,type:t_double,pos:288,shift:0,length: 0}, $
                {name:'pos_gcif_moonwrtearthz'  ,type:t_double,pos:296,shift:0,length: 0}, $
                {name:'vel_gcif_moonwrtearthx'  ,type:t_double,pos:304,shift:0,length: 0}, $
                {name:'vel_gcif_moonwrtearthy'  ,type:t_double,pos:312,shift:0,length: 0}, $
                {name:'vel_gcif_moonwrtearthz'  ,type:t_double,pos:320,shift:0,length: 0}, $
                {name:'unit_gcif_moonwrtearthx' ,type:t_double,pos:328,shift:0,length: 0}, $
                {name:'unit_gcif_moonwrtearthy' ,type:t_double,pos:336,shift:0,length: 0}, $
                {name:'unit_gcif_moonwrtearthz' ,type:t_double,pos:344,shift:0,length: 0}, $
                {name:'pos_gcif_gndwrtearthx'   ,type:t_double,pos:352,shift:0,length: 0}, $
                {name:'pos_gcif_gndwrtearthy'   ,type:t_double,pos:360,shift:0,length: 0}, $
                {name:'pos_gcif_gndwrtearthz'   ,type:t_double,pos:368,shift:0,length: 0}, $
                {name:'pos_gcif_sunwrtsc_aberrx',type:t_double,pos:376,shift:0,length: 0}, $
                {name:'pos_gcif_sunwrtsc_aberry',type:t_double,pos:384,shift:0,length: 0}, $
                {name:'pos_gcif_sunwrtsc_aberrz',type:t_double,pos:392,shift:0,length: 0}, $
                {name:'unit_sun_gcif_aberrx'    ,type:t_double,pos:400,shift:0,length: 0}, $
                {name:'unit_sun_gcif_aberry'    ,type:t_double,pos:408,shift:0,length: 0}, $
                {name:'unit_sun_gcif_aberrz'    ,type:t_double,pos:416,shift:0,length: 0}, $
                {name:'unit_sun_gcif_geomx'     ,type:t_double,pos:424,shift:0,length: 0}, $
                {name:'unit_sun_gcif_geomy'     ,type:t_double,pos:432,shift:0,length: 0}, $
                {name:'unit_sun_gcif_geomz'     ,type:t_double,pos:440,shift:0,length: 0}, $
                {name:'unit_moon_gcif_geomx'    ,type:t_double,pos:448,shift:0,length: 0}, $
                {name:'unit_moon_gcif_geomy'    ,type:t_double,pos:456,shift:0,length: 0}, $
                {name:'unit_moon_gcif_geomz'    ,type:t_double,pos:464,shift:0,length: 0}, $
                {name:'time_sys_utc'            ,type:t_double,pos:472,shift:0,length: 0}, $
                {name:'time_ephem_prop'         ,type:t_double,pos:480,shift:0,length: 0}, $
                {name:'FLAG_EPHEMENABLED'       ,type:t_u8    ,pos:488,shift:0,length: 0}, $
                {name:'FLAG_EPHEM_STALE'        ,type:t_u8    ,pos:489,shift:0,length: 0}, $
                {name:'FLAG_EPVPRESENT'         ,type:t_u8    ,pos:490,shift:0,length: 0}, $
                {name:'FLAG_GOODSCEPHEM'        ,type:t_u8    ,pos:491,shift:0,length: 0}, $
                {name:'FLAG_ECLIPSE_EPHEM'      ,type:t_u8    ,pos:492,shift:0,length: 0}, $
                {name:'FLAG_STVELCMD_ENABLED'   ,type:t_u8    ,pos:493,shift:0,length: 0}, $
                {name:'FLAG_CONTINUITYCHK'      ,type:t_u8    ,pos:494,shift:0,length: 0}, $
                {name:'EPHEMDATA__SPARE2'       ,type:t_u8    ,pos:495,shift:0,length: 0}  $
              ])}

  eve_hk_pkt_desc={name:"EVE Housekeeping",apid:79U,length:181U,fields:ptr_new([ $
                *ccsds_header_pkt_desc.fields, $
                {name:'tai_sec'               ,type:t_u32,pos:  6,shift:0,length: 0}, $
                {name:'tai_subsec'            ,type:t_u32,pos: 10,shift:0,length: 0}, $ 
                {name:'megs_a_cebpcb_temp'    ,type:t_u16,pos: 16,shift:0,length:12}, $
                {name:'megs_a_cprpcb_temp'    ,type:t_u16,pos: 18,shift:0,length:12}, $
                {name:'megs_a_p24v'           ,type:t_u16,pos: 20,shift:0,length:12}, $
                {name:'megs_a_p15v'           ,type:t_u16,pos: 22,shift:0,length:12}, $
                {name:'megs_a_m15v'           ,type:t_u16,pos: 24,shift:0,length:12}, $
                {name:'megs_a_p5v'            ,type:t_u16,pos: 26,shift:0,length:12}, $
                {name:'megs_a_m5v'            ,type:t_u16,pos: 28,shift:0,length:12}, $
                {name:'megs_a_p5v_digital'    ,type:t_u16,pos: 30,shift:0,length:12}, $
                {name:'megs_a_p2_5v'          ,type:t_u16,pos: 32,shift:0,length:12}, $
                {name:'megs_a_p24v_cur'       ,type:t_u16,pos: 34,shift:0,length:12}, $
                {name:'megs_a_p15v_cur'       ,type:t_u16,pos: 36,shift:0,length:12}, $
                {name:'megs_a_m15v_cur'       ,type:t_u16,pos: 38,shift:0,length:12}, $
                {name:'megs_a_p5v_cur'        ,type:t_u16,pos: 40,shift:0,length:12}, $
                {name:'megs_a_m5v_cur'        ,type:t_u16,pos: 42,shift:0,length:12}, $
                {name:'megs_a_p5v_digital_cur',type:t_u16,pos: 44,shift:0,length:12}, $
                {name:'megs_a_p2_5v_cur'      ,type:t_u16,pos: 46,shift:0,length:12}, $
                {name:'megs_b_cebpcb_temp'    ,type:t_u16,pos: 48,shift:0,length:12}, $
                {name:'megs_b_cprpcb_temp'    ,type:t_u16,pos: 50,shift:0,length:12}, $
                {name:'megs_b_p24v'           ,type:t_u16,pos: 52,shift:0,length:12}, $
                {name:'megs_b_p15v'           ,type:t_u16,pos: 54,shift:0,length:12}, $
                {name:'megs_b_m15v'           ,type:t_u16,pos: 56,shift:0,length:12}, $
                {name:'megs_b_p5v'            ,type:t_u16,pos: 58,shift:0,length:12}, $
                {name:'megs_b_m5v'            ,type:t_u16,pos: 60,shift:0,length:12}, $
                {name:'megs_b_p5v_digital'    ,type:t_u16,pos: 62,shift:0,length:12}, $
                {name:'megs_b_p2_5v'          ,type:t_u16,pos: 64,shift:0,length:12}, $
                {name:'megs_b_p24v_cur'       ,type:t_u16,pos: 66,shift:0,length:12}, $
                {name:'megs_b_p15v_cur'       ,type:t_u16,pos: 68,shift:0,length:12}, $
                {name:'megs_b_m15v_cur'       ,type:t_u16,pos: 70,shift:0,length:12}, $
                {name:'megs_b_p5v_cur'        ,type:t_u16,pos: 72,shift:0,length:12}, $
                {name:'megs_b_m5v_cur'        ,type:t_u16,pos: 74,shift:0,length:12}, $
                {name:'megs_b_p5v_digital_cur',type:t_u16,pos: 76,shift:0,length:12}, $
                {name:'megs_b_p2_5v_cur'      ,type:t_u16,pos: 78,shift:0,length:12}, $
                {name:'megs_a_p28v_cur'       ,type:t_u16,pos: 80,shift:0,length:12}, $
                {name:'megs_b_p28v_cur'       ,type:t_u16,pos: 82,shift:0,length:12}, $
                {name:'esp_p28v_cur'          ,type:t_u16,pos: 84,shift:0,length:12}, $
                {name:'megs_a_op_htr_cur'     ,type:t_u16,pos: 86,shift:0,length:12}, $
                {name:'megs_b_op_htr_cur'     ,type:t_u16,pos: 88,shift:0,length:12}, $
                {name:'eop_op_htr_cur'        ,type:t_u16,pos: 90,shift:0,length:12}, $
                {name:'eeb_ice_p3_3v_cur'     ,type:t_u16,pos: 92,shift:0,length:12}, $
                {name:'eeb_lvpc_temp'         ,type:t_u16,pos: 94,shift:0,length:12}, $
                {name:'megs_a_ccd_temp'       ,type:t_u16,pos: 96,shift:0,length:12}, $
                {name:'megs_b_ccd_temp'       ,type:t_u16,pos: 98,shift:0,length:12}, $
                {name:'eeb_p15v'              ,type:t_u16,pos:100,shift:0,length:12}, $
                {name:'eeb_m15v'              ,type:t_u16,pos:102,shift:0,length:12}, $
                {name:'eeb_p5v'               ,type:t_u16,pos:104,shift:0,length:12}, $
                {name:'eeb_p3_3v'             ,type:t_u16,pos:106,shift:0,length:12}, $
                {name:'megs_a_rad_ctrl_temp'  ,type:t_u16,pos:108,shift:0,length:12}, $
                {name:'megs_b_rad_ctrl_temp'  ,type:t_u16,pos:110,shift:0,length:12}, $
                {name:'eop_ctrl_temp'         ,type:t_u16,pos:112,shift:0,length:12}, $
                {name:'eeb_ps_p2_5v'          ,type:t_u16,pos:114,shift:0,length:12}, $
                {name:'eeb_ps_p2_5v_cur'      ,type:t_u16,pos:116,shift:0,length:12}, $
                {name:'megs_a_lvpc_temp'      ,type:t_u16,pos:118,shift:0,length:12}, $
                {name:'megs_b_lvpc_temp'      ,type:t_u16,pos:120,shift:0,length:12}, $
                {name:'eeb_ps_p3_3v_cur'      ,type:t_u16,pos:122,shift:0,length:12}, $
                {name:'eeb_ice_p2_5v'         ,type:t_u16,pos:124,shift:0,length:12}, $
                {name:'esp_hv_monitor'        ,type:t_u16,pos:126,shift:0,length:12}, $
                {name:'esp_p2_5v'             ,type:t_u16,pos:128,shift:0,length:12}, $
                {name:'esp_det_temp'          ,type:t_u16,pos:130,shift:0,length:12}, $
                {name:'esp_elec_temp'         ,type:t_u16,pos:132,shift:0,length:12}, $
                {name:'esp_lvps_temp'         ,type:t_u16,pos:134,shift:0,length:12}, $
                {name:'esp_p12v'              ,type:t_u16,pos:136,shift:0,length:12}, $
                {name:'eeb_ice_p2_5v_cur'     ,type:t_u16,pos:138,shift:0,length:12}, $
                {name:'sdn_therm_ref_cur'     ,type:t_u16,pos:140,shift:0,length:12}, $
                {name:'sdn_core_therm'        ,type:t_u16,pos:142,shift:0,length:12}, $
                {name:'sdn_p2_5v'             ,type:t_u16,pos:144,shift:0,length:12}, $
                {name:'sdn_p3_3v'             ,type:t_u16,pos:146,shift:0,length:12}, $
                {name:'sdn_p5v'               ,type:t_u16,pos:148,shift:0,length:12}, $
                {name:'sdn_p15v'              ,type:t_u16,pos:150,shift:0,length:12}, $
                {name:'sdn_m15v'              ,type:t_u16,pos:152,shift:0,length:12}, $
                {name:'sdn_a_grnd_ref1'       ,type:t_u16,pos:154,shift:0,length:12}, $
                {name:'sdn_a_grnd_ref2'       ,type:t_u16,pos:156,shift:0,length:12}, $
                {name:'sdn_adc_ref'           ,type:t_u16,pos:158,shift:0,length:12}, $
                {name:'ps_core_therm'         ,type:t_u16,pos:160,shift:0,length:12}, $
                {name:'esp_door_temp'         ,type:t_u16,pos:162,shift:0,length:12}, $
                {name:'sam_door_temp'         ,type:t_u16,pos:164,shift:0,length:12}, $
                {name:'ma_door_temp'          ,type:t_u16,pos:166,shift:0,length:12}, $
                {name:'mb_door_temp'          ,type:t_u16,pos:168,shift:0,length:12}, $
                {name:'megs_p_temp'           ,type:t_u16,pos:170,shift:0,length:12}, $
                {name:'eop_pxpy_temp'         ,type:t_u16,pos:172,shift:0,length:12}, $
                {name:'eop_mxpy_temp'         ,type:t_u16,pos:174,shift:0,length:12}, $
                {name:'sdn_therm10'           ,type:t_u16,pos:176,shift:0,length:12}, $
                {name:'sdn_therm11'           ,type:t_u16,pos:178,shift:0,length:12}, $
                {name:'sdn_therm12'           ,type:t_u16,pos:180,shift:0,length:12}, $
                {name:'sdn_therm13'           ,type:t_u16,pos:182,shift:0,length:12}, $
                {name:'sdn_therm14'           ,type:t_u16,pos:184,shift:0,length:12}, $
                {name:'sdn_therm15'           ,type:t_u16,pos:186,shift:0,length:12}  $
             ])}
  eve_slow_pkt_desc={name:"EVE Slow",apid:78U,length:149U,fields:ptr_new([ $
                *ccsds_header_pkt_desc.fields, $
                {name:'tai_sec'                ,type:t_u32,pos:  6,shift:0,length:0}, $
                {name:'tai_subsec'             ,type:t_u32,pos: 10,shift:0,length:0}, $ 
                {name:'megs_a_bot_rdout'       ,type:t_u8, pos: 16,shift:2,length:1}, $ ;This field overlaps megs_a_top_rdout
                {name:'megs_a_top_rdout'       ,type:t_u8, pos: 16,shift:1,length:1}, $ ;So does this one. This can't be right.
                {name:'megs_a_integ_time'      ,type:t_u8, pos: 16,shift:0,length:0}, $ 
                {name:'megs_a_mux_addr'        ,type:t_u16,pos: 18,shift:0,length:0}, $ 
                {name:'megs_a_timeout_error'   ,type:t_u8, pos: 21,shift:5,length:2}, $
                {name:'megs_a_reverseclk_err'  ,type:t_u8, pos: 21,shift:4,length:1}, $
                {name:'megs_a_reverseclk_state',type:t_u8, pos: 21,shift:3,length:1}, $
                {name:'megs_a_dreg_cmd_error'  ,type:t_u8, pos: 21,shift:1,length:2}, $
                {name:'megs_a_integ_cnt'       ,type:t_u16,pos: 22,shift:0,length:0}, $ 
                {name:'megs_a_cmd_exec_err'    ,type:t_u16,pos: 24,shift:0,length:0}, $ 
                {name:'megs_a_fpga_version'    ,type:t_u16,pos: 26,shift:0,length:0}, $ 
                {name:'megs_a_rate_meter_top'  ,type:t_u16,pos: 28,shift:0,length:0}, $ 
                {name:'megs_a_rate_meter_bot'  ,type:t_u16,pos: 30,shift:0,length:0}, $ 
                {name:'megs_b_bot_rdout'       ,type:t_u8, pos: 32,shift:2,length:1}, $
                {name:'megs_b_top_rdout'       ,type:t_u8, pos: 32,shift:1,length:1}, $
                {name:'megs_b_integ_time'      ,type:t_u8, pos: 32,shift:0,length:0}, $ 
                {name:'megs_b_mux_addr'        ,type:t_u16,pos: 34,shift:0,length:0}, $ 
                {name:'megs_b_timeout_error'   ,type:t_u8, pos: 37,shift:5,length:2}, $
                {name:'megs_b_reverseclk_err'  ,type:t_u8, pos: 37,shift:4,length:1}, $
                {name:'megs_b_reverseclk_state',type:t_u8, pos: 37,shift:3,length:1}, $
                {name:'megs_b_dreg_cmd_error'  ,type:t_u8, pos: 37,shift:1,length:2}, $
                {name:'megs_b_integ_cnt'       ,type:t_u16,pos: 38,shift:0,length:0}, $ 
                {name:'megs_b_cmd_exec_err'    ,type:t_u16,pos: 40,shift:0,length:0}, $ 
                {name:'megs_b_fpga_version'    ,type:t_u16,pos: 42,shift:0,length:0}, $ 
                {name:'megs_b_rate_meter_top'  ,type:t_u16,pos: 44,shift:0,length:0}, $ 
                {name:'megs_b_rate_meter_bot'  ,type:t_u16,pos: 46,shift:0,length:0}, $ 
                {name:'megs_p_shk_volt_ref'    ,type:t_u8, pos: 48,shift:1,length:1}, $
                {name:'megs_p_shk_valid'       ,type:t_u8, pos: 48,shift:0,length:1}, $
                {name:'esp_shk_xfer'           ,type:t_u8, pos: 49,shift:2,length:6}, $
                {name:'esp_shk_volt_ref'       ,type:t_u8, pos: 49,shift:1,length:1}, $
                {name:'esp_shk_valid'          ,type:t_u8, pos: 49,shift:0,length:1}, $
                {name:'esp_366'                ,type:t_u16,pos: 50,shift:0,length:0}, $ 
                {name:'esp_257'                ,type:t_u16,pos: 52,shift:0,length:0}, $ 
                {name:'esp_dark'               ,type:t_u16,pos: 54,shift:0,length:0}, $ 
                {name:'esp_q2'                 ,type:t_u16,pos: 56,shift:0,length:0}, $ 
                {name:'esp_q0'                 ,type:t_u16,pos: 58,shift:0,length:0}, $ 
                {name:'esp_q1'                 ,type:t_u16,pos: 60,shift:0,length:0}, $ 
                {name:'esp_q3'                 ,type:t_u16,pos: 62,shift:0,length:0}, $ 
                {name:'esp_171'                ,type:t_u16,pos: 64,shift:0,length:0}, $ 
                {name:'esp_304'                ,type:t_u16,pos: 66,shift:0,length:0}, $ 
                {name:'megs_p_photometer_lya'  ,type:t_u16,pos: 68,shift:0,length:0}, $ 
                {name:'megs_p_photometer_drk'  ,type:t_u16,pos: 70,shift:0,length:0}, $ 
                {name:'megs_a_dma_addr'        ,type:t_u32,pos: 72,shift:0,length:0}, $ 
                {name:'megs_b_dma_addr'        ,type:t_u32,pos: 76,shift:0,length:0}, $ 
                {name:'esp_data_xfer_status'   ,type:t_u8, pos: 80,shift:0,length:0}, $ 
                {name:'esp_xfer_idx'           ,type:t_u8, pos: 81,shift:0,length:0}, $ 
                {name:'megs_b_shk_integ_time'  ,type:t_u8, pos: 84,shift:0,length:0}, $ 
                {name:'megs_b_shk_sw_testpat'  ,type:t_u8, pos: 85,shift:7,length:1}, $
                {name:'megs_b_shk_reverseclk'  ,type:t_u8, pos: 85,shift:6,length:1}, $
                {name:'megs_b_shk_bot_rdout'   ,type:t_u8, pos: 85,shift:5,length:1}, $
                {name:'megs_b_shk_top_rdout'   ,type:t_u8, pos: 85,shift:4,length:1}, $
                {name:'megs_b_shk_integ_wrn'   ,type:t_u8, pos: 85,shift:3,length:1}, $
                {name:'megs_b_shk_hw_testpat'  ,type:t_u8, pos: 85,shift:2,length:1}, $
                {name:'megs_b_shk_bank_select' ,type:t_u8, pos: 85,shift:1,length:1}, $
                {name:'megs_b_data_valid'      ,type:t_u8, pos: 85,shift:0,length:1}, $
                {name:'megs_a_shk_integ_time'  ,type:t_u8, pos: 86,shift:0,length:0}, $ 
                {name:'megs_a_shk_sw_testpat'  ,type:t_u8, pos: 87,shift:7,length:1}, $
                {name:'megs_a_shk_reverseclk'  ,type:t_u8, pos: 87,shift:6,length:1}, $
                {name:'megs_a_shk_bot_rdout'   ,type:t_u8, pos: 87,shift:5,length:1}, $
                {name:'megs_a_shk_top_rdout'   ,type:t_u8, pos: 87,shift:4,length:1}, $
                {name:'megs_a_shk_integ_wrn'   ,type:t_u8, pos: 87,shift:3,length:1}, $
                {name:'megs_a_shk_hw_testpat'  ,type:t_u8, pos: 87,shift:2,length:1}, $
                {name:'megs_a_shk_bank_select' ,type:t_u8, pos: 87,shift:1,length:1}, $
                {name:'megs_a_data_valid'      ,type:t_u8, pos: 87,shift:0,length:1}, $
                {name:'megs_b_xfer_err'        ,type:t_u8, pos: 90,shift:2,length:2}, $
                {name:'megs_a_xfer_err'        ,type:t_u8, pos: 90,shift:0,length:2}, $
                {name:'spif_hk_received'       ,type:t_u8, pos: 91,shift:6,length:2}, $
                {name:'megs_b_parity_bot_error',type:t_u8, pos: 91,shift:5,length:1}, $
                {name:'megs_b_parity_top_error',type:t_u8, pos: 91,shift:4,length:1}, $
                {name:'megs_b_frame_error'     ,type:t_u8, pos: 91,shift:3,length:1}, $
                {name:'megs_a_parity_bot_error',type:t_u8, pos: 91,shift:2,length:1}, $
                {name:'megs_a_parity_top_error',type:t_u8, pos: 91,shift:1,length:1}, $
                {name:'megs_a_frame_error'     ,type:t_u8, pos: 91,shift:0,length:1}, $
                {name:'spif_status_reg'        ,type:t_u32,pos: 92,shift:0,length:0}, $ 
                {name:'swif_hill_cksum_error'  ,type:t_u8, pos: 96,shift:7,length:1}, $
                {name:'swif_dma_underrun_err'  ,type:t_u8, pos: 96,shift:6,length:1}, $
                {name:'swif_dma_timeout_err'   ,type:t_u8, pos: 96,shift:5,length:1}, $
                {name:'swif_atmel_read_stat'   ,type:t_u8, pos: 96,shift:4,length:1}, $
                {name:'swif_atmel_write_stat'  ,type:t_u8, pos: 96,shift:3,length:1}, $
                {name:'swif_hill_dma_status'   ,type:t_u8, pos: 96,shift:2,length:1}, $
                {name:'swif_dma_status'        ,type:t_u8, pos: 96,shift:0,length:2}, $
                {name:'swif_hsb_irq_status'    ,type:t_u8, pos: 97,shift:7,length:1}, $
                {name:'swif_por_hw_reset'      ,type:t_u8, pos: 97,shift:6,length:1}, $
                {name:'swif_hw_reset'          ,type:t_u8, pos: 97,shift:5,length:1}, $
                {name:'swif_impdu_fifo_stat'   ,type:t_u8, pos: 97,shift:4,length:1}, $
                {name:'swif_sm_read_status'    ,type:t_u8, pos: 97,shift:3,length:1}, $
                {name:'swif_impdu_underrun'    ,type:t_u8, pos: 97,shift:2,length:1}, $
                {name:'swif_impdu_overrun'     ,type:t_u8, pos: 97,shift:1,length:1}, $
                {name:'swif_bank_select'       ,type:t_u8, pos: 97,shift:0,length:1}, $
                {name:'spif_interrupt'         ,type:t_u32,pos:100,shift:0,length:0}, $ 
                {name:'spif_interrupt_ss'      ,type:t_u32,pos:104,shift:0,length:0}, $ 
                {name:'swif_interrupt'         ,type:t_u32,pos:108,shift:0,length:0}, $ 
                {name:'swif_interrupt_ss'      ,type:t_u32,pos:112,shift:0,length:0}, $ 
                {name:'megs_rate_meter_ts'     ,type:t_u32,pos:116,shift:0,length:0}, $ 
                {name:'megs_rate_meter_ts_ss'  ,type:t_u32,pos:120,shift:0,length:0}, $ 
                {name:'mu_hb_slw_cadnc_idx'    ,type:t_u8, pos:124,shift:0,length:0}, $ 
                {name:'mu_hb_spif_intrpt_cnt'  ,type:t_u8, pos:125,shift:0,length:0}, $ 
                {name:'mu_ram_major_ver'       ,type:t_u8, pos:128,shift:0,length:0}, $ 
                {name:'mu_ram_minor_ver'       ,type:t_u8, pos:129,shift:0,length:0}, $ 
                {name:'mu_cp_slw_cadnc_idx'    ,type:t_u8, pos:132,shift:0,length:0}, $ 
                {name:'megs_a_ccd_lo_trip_cnt' ,type:t_u8, pos:136,shift:0,length:0}, $ 
                {name:'megs_a_ccd_hi_trip_cnt' ,type:t_u8, pos:137,shift:0,length:0}, $ 
                {name:'megs_b_ccd_lo_trip_cnt' ,type:t_u8, pos:138,shift:0,length:0}, $ 
                {name:'megs_b_ccd_hi_trip_cnt' ,type:t_u8, pos:139,shift:0,length:0}, $ 
                {name:'mu_tp_trgt_err_tot'     ,type:t_u16,pos:140,shift:0,length:0}, $ 
                {name:'mu_tp_pci_err_tot'      ,type:t_u16,pos:142,shift:0,length:0}, $ 
                {name:'mu_tp_os_err_tot'       ,type:t_u16,pos:144,shift:0,length:0}, $ 
                {name:'mu_tp_sb_err_tot'       ,type:t_u16,pos:146,shift:0,length:0}, $ 
                {name:'mu_tp_exec_cnt_tot'     ,type:t_u32,pos:148,shift:0,length:0}, $ 
                {name:'mu_tp_slw_cadnc_idx'    ,type:t_u8, pos:152,shift:0,length:0}, $ 
                {name:'mu_hb_slow_tlm_stat'    ,type:t_u8, pos:153,shift:2,length:1}, $
                {name:'mu_tp_slow_tlm_stat'    ,type:t_u8, pos:153,shift:2,length:1}, $
                {name:'mu_cp_slow_tlm_stat'    ,type:t_u8, pos:153,shift:1,length:1}  $
             ])}
  eve_fast_pkt_desc={name:"EVE Slow",apid:76U,length:161U,fields:ptr_new([ $
                *ccsds_header_pkt_desc.fields, $
                {name:'tai_sec'                ,type:t_u32,pos:  6     ,shift:0 ,length:0}, $
                {name:'tai_subsec'             ,type:t_u32,pos: 10     ,shift:0 ,length:0}, $ 
                {name:'megs_a_fltrwhl_moving'  ,type:t_u16,pos: 27*2+14,shift:15,length:1}, $ 
                {name:'megs_a_fltrwhl_dir'     ,type:t_u16,pos: 27*2+14,shift:14,length:1}, $ 
                {name:'megs_a_fltrwhl_pos_kn'  ,type:t_u16,pos: 27*2+14,shift:13,length:1}, $ 
                {name:'megs_a_fltrwhl_mode'    ,type:t_u16,pos: 27*2+14,shift:12,length:1}, $ 
                {name:'megs_a_fltrwhl_oper'    ,type:t_u16,pos: 27*2+14,shift: 8,length:4}, $ 
                {name:'megs_b_fltrwhl_moving'  ,type:t_u16,pos: 27*2+14,shift: 7,length:1}, $ 
                {name:'megs_b_fltrwhl_dir'     ,type:t_u16,pos: 27*2+14,shift: 6,length:1}, $ 
                {name:'megs_b_fltrwhl_pos_kn'  ,type:t_u16,pos: 27*2+14,shift: 5,length:1}, $ 
                {name:'megs_b_fltrwhl_mode'    ,type:t_u16,pos: 27*2+14,shift: 4,length:1}, $ 
                {name:'megs_b_fltrwhl_oper'    ,type:t_u16,pos: 27*2+14,shift: 0,length:4}, $ 
                {name:'sam_fltrwhl_moving'     ,type:t_u16,pos: 28*2+14,shift:15,length:1}, $ 
                {name:'sam_fltrwhl_dir'        ,type:t_u16,pos: 28*2+14,shift:14,length:1}, $ 
                {name:'sam_fltrwhl_pos_kn'     ,type:t_u16,pos: 28*2+14,shift:13,length:1}, $ 
                {name:'sam_fltrwhl_mode'       ,type:t_u16,pos: 28*2+14,shift:12,length:1}, $ 
                {name:'sam_fltrwhl_oper'       ,type:t_u16,pos: 28*2+14,shift: 8,length:4}, $ 
                {name:'esp_fltrwhl_moving'     ,type:t_u16,pos: 28*2+14,shift: 7,length:1}, $ 
                {name:'esp_fltrwhl_dir'        ,type:t_u16,pos: 28*2+14,shift: 6,length:1}, $ 
                {name:'esp_fltrwhl_pos_kn'     ,type:t_u16,pos: 28*2+14,shift: 5,length:1}, $ 
                {name:'esp_fltrwhl_mode'       ,type:t_u16,pos: 28*2+14,shift: 4,length:1}, $ 
                {name:'esp_fltrwhl_oper'       ,type:t_u16,pos: 28*2+14,shift: 0,length:4}, $ 
                {name:'megs_a_fltrwhl_step_req',type:t_u16,pos: 29*2+14,shift: 0,length:0}, $ 
                {name:'megs_b_fltrwhl_step_req',type:t_u16,pos: 30*2+14,shift: 0,length:0}, $ 
                {name:'sam_fltrwhl_step_req'   ,type:t_u16,pos: 31*2+14,shift: 0,length:0}, $ 
                {name:'esp_fltrwhl_step_req'   ,type:t_u16,pos: 32*2+14,shift: 0,length:0}, $ 
                {name:'megs_a_fltrwhl_step_num',type:t_u16,pos: 33*2+14,shift: 0,length:0}, $ 
                {name:'megs_b_fltrwhl_step_num',type:t_u16,pos: 34*2+14,shift: 0,length:0}, $ 
                {name:'sam_fltrwhl_step_num'   ,type:t_u16,pos: 35*2+14,shift: 0,length:0}, $ 
                {name:'esp_fltrwhl_step_num'   ,type:t_u16,pos: 36*2+14,shift: 0,length:0}, $ 
                {name:'megs_a_fltrwhl_rslvr'   ,type:t_u16,pos: 37*2+14,shift: 0,length:0}, $ 
                {name:'megs_b_fltrwhl_rslvr'   ,type:t_u16,pos: 38*2+14,shift: 0,length:0}, $ 
                {name:'sam_fltrwhl_rslvr'      ,type:t_u16,pos: 39*2+14,shift: 0,length:0}, $ 
                {name:'esp_fltrwhl_rslvr'      ,type:t_u16,pos: 40*2+14,shift: 0,length:0}  $ 
             ])}
  return,[ccsds_header_pkt_desc,acs_pkt_desc,ephem_pkt_desc,eve_hk_pkt_desc,eve_slow_pkt_desc,eve_fast_pkt_desc]
end

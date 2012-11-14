function iuvs_make_keyword,header,level
  common iuvs_make_keyword_static,init

  cspice_str2et,systime(/utc)+"UTC",et_pro
  cspice_et2utc,et_pro          ,"ISOD",0,utcstr_pro
  cspice_et2utc,header.timestamp,"ISOD",5,utcstr_cap

  kw_replace=[['START_TIME','START_S'], $
              ['START_TIME__SUB','START_SS'], $
              ['CADENCE',''],$
              ['INT_TIME',''], $
              ['NUMBER',''],$
              ['MIRROR_POS','MIR_POS'],$
              ['MIRROR_THIS_DN','MIR_DN'],$
              ['MIRROR_THIS_DEG','MIR_DEG'],$
              ['STEP_NUM',''],$
              ['STEP_SIZE','STEP_SIZ'],$
              ['STEP_INT',''],$
              ['BIN_SHIFT','BIN_SHFT'], $
              ['OBS_ID',''],$
              ['FUV_BAD_PIXEL_MASK','FUV_MASK'],$
              ['MUV_BAD_PIXEL_MASK','MUV_MASK'],$
              ['DATA_COMPRESSION','WAS_COMP'],$
              ['TEST_PATTERN','TEST_PAT'],$
              ['ON_CHIP_WINDOWING','ON_CHIPW'],$
              ['BIN_TYPE',''],$
              ['SCAN_MODE','SCANMODE'],$
              ['MODE',''], $
              ['TIME_FLAG','TIMEFLAG'], $
              ['SHUTTER_ON','SHUT_ON'], $
              ['SHUTTER_OFF','SHUT_OFF'],$
              ['SHUTTER_NUM','SHUT_NUM'],$
              ['SET_TOTAL','SET_TOT'],$
              ['BIN_X_ROW','BINX_ROW'],$
              ['BIN_Y_ROW','BINY_ROW'],$
              ['DET_TEMP',''],$
              ['CASE_TEMP','CAS_TEMP'],$
              ['MCP_GAIN',''],$
              ['LENGTH',''],$
              ['IMAGE_NUMBER','IMG_NUM'],$
              ['AVERAGE',''],$
              ['CHECKSUM',''],$
              ['XUV',''],$
              ['TIMESTAMP','TIMESTMP'],$
              ['SEQ',''],$
              ['NAME','$SKIP'],$
              ['VER','$SKIP'],$
              ['TYPE','$SKIP'],$
              ['SCND_HDR','$SKIP'],$
              ['APID','$SKIP'],$
              ['GRP_FLG','$SKIP'],$
              ['SSC','$SKIP'],$
              ['DATA_LEN','$SKIP'],$
              ['SC_CLK_COARSE','$SKIP'],$
              ['SC_CLK_FINE','$SKIP'],$
              ['DFB_TERTIARY','$SKIP'],$
              ['SCI_PKT_CKSUM','$SKIP'],$
              ['SCI_ERR_FLAGS','$SKIP'],$
              ['SCI_IMG_DET_IS_MUV','$SKIP']]
              
  type_fmt=['',       $ ; 0, undefined
            '%20d',     $ ; 1, 8 bit unsigned
            '%20d',     $ ; 2, 16 bit signed 
            '%20d',     $ ; 3, 32 bit signed
            '%20.7e', $ ; 4, 32 bit float
            '%20.13e',$ ; 5, 64 bit float
            '',       $ ; 6, 32x2 bit complex
            '''%s''', $ ; 7, string
            '',       $ ; 8, structure
            '',       $ ; 9, 64x2 bit complex
            '',       $ ;10, pointer
            '',       $ ;11, object
            '%20d',     $ ;12, 16 bit unsigned
            '%20d',     $ ;13, 32 bit unsigned
            '%20d',     $ ;14, 64 bit signed
            '%20d']       ;15, 64 bit unsigned

  t=tag_names(header)
  h=['COMMENT MAVEN IUVS Level '+level+' Data Product', $
     'COMMENT IUVS Principal Investigator N. Schneider', $
     'COMMENT Laboratory for Atmospheric and Space Physics', $
     'COMMENT University of Colorado Boulder', $
     'COMMENT 1234 Innovation Drive, Boulder CO 80303', $
     'COMMENT MAVEN Mission scientific and model results are open to all.', $
     'COMMENT Users should contact the PI or designated IUVS team member early in an', $
     'COMMENT analysis project to discuss appropriate use of instrument data results.',$
     'COMMENT Appropriate acknowledgement to institutions, personnel, and funding', $
     'COMMENT agencies should be given. Version numbers should also be specified.', $
     "PROCESS = '"+utcstr_pro+"UTC' /File processing time",$
     "CAPTURE = '"+utcstr_cap+"UTC' /Data capture time"]
     
  for i=0,n_elements(t)-1 do begin
    w=where(t[i] eq kw_replace[0,*],count)
    if count gt 0 then begin
      this_u=kw_replace[1,w[0]]
      if this_u eq '' then this_u=t[i]
      if this_u eq "$SKIP" then continue
    end else begin
      this_u=strmid(t[i],0,8)
    end
    if n_elements(header.(i)) gt 1 then continue
    this_v=string(header.(i),format='(%"'+type_fmt[size(/type,header.(i))]+'")')
    if t[i] eq this_u then this_c='' else this_c=' //'+t[i]
    this_h=strmid(string(format='(%"%-8s= %s%s")',this_u,this_v,this_c),0,80)
    if n_elements(u) eq 0 then begin
      u=this_u
      v=this_v
    end else begin
      u=[u,this_u]
      v=[v,this_v]
    end
    h=[h,this_h]
  end
  return,h
end

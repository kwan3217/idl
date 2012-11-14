;Given a key from the left side of a key/value pair in an IUVS header file,
;convert it into a string which can be used as an IDL identifier
;Example: 
;  Input:
;    The Rain In Spain (in mm)
;  Output:
;    THE_RAIN_IN_SPAIN__IN_MM
;Right now it just turns spaces and parentheses into underscores. If one of these
;symbols is at the end, the _ is left off (see above)
function iuvs_header_fix_key,key_
  key=strtrim(strupcase(key_),2)
  w=strpos(key,' ')
  key=strjoin(strsplit(key,' ',/extract),'_')
  key=strjoin(strsplit(key,'(',/extract),'_')
  key=strjoin(strsplit(key,')',/extract),'_')
  return,key
end

function iuvs_timestamp,time_sec,time_subsec,cadence,seq
  if n_elements(cadence) eq 0 then c=0d else c=double(cadence)*double(seq)/1000d
  return,double(time_sec)+double(time_subsec)/65536d +c
end

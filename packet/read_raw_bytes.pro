function read_raw_bytes,inf,length,data
  if eof(inf) then return,0
  data=bytarr(length)
  readu,inf,data
  return,1
end

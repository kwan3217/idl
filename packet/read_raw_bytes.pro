function read_raw_bytes,inf,length,data
  if eof(inf) then return,0
  data=bytarr(length)
  errno=0
  catch,errno
  if errno eq 0 then begin
    readu,inf,data
  end else begin
    catch,/cancel
    return,0
  end
  return,1
end

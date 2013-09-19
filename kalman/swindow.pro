pro swindow,w
  errno=0
  catch,errno
  if errno eq 0 then wset,w else window,w
  catch,/cancel
end
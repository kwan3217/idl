pro toc,message,lun,lasttoc=lasttoc,firsttoc=firsttoc

common Tictoc, firsttic, lasttic
if n_elements(message) gt 0 then begin
  if n_elements(lun) eq 0 then begin
    print,message
  end else begin
    write2log,lun,message
  end
end

if n_elements(firsttic) eq 0 then begin
  tic
  return
end
thistoc=systime(/seconds)

lasttoc=thistoc-lasttic
firsttoc=thistoc-firsttic

msg=string(format='(%"Elapsed time is %fs")',lasttoc)
if n_elements(lun) eq 0 then begin
  print,msg
end else begin
  write2log,lun,msg
end

if(lasttic ne firsttic) then begin
  msg=string(format='(%"Total Elapsed time is %fs")',firsttoc)
  if n_elements(lun) eq 0 then begin
    print,msg
  end else begin
    write2log,lun,msg
  end
end

lasttic=thistoc

end

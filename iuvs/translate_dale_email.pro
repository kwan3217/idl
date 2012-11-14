pro translate_dale_email,s,bin_width=bin_width,bin_transmit=bin_transmit
  result=toHex(s,2)
  bin_width=(result mod 128)+1
  bin_transmit=1-(result/128)
  
  ;Bound things within the 1024 pixel area of the detector
  bin_stop=total(/c,bin_width)-1
  bin_start=bin_stop+1-bin_width
  w=where(bin_start le 1023,count)
  if count gt 0 then begin
    bin_start=bin_start[w]
    bin_stop=bin_stop[w]
    bin_transmit=bin_transmit[w]
  end else begin
    message,"Can't happen"
  end
  w=where(bin_stop ge 1024,count)
  if count gt 0 then bin_stop[w]=1023
  bin_width=bin_stop-bin_start+1
  print,bin_width,bin_transmit
  print,total(bin_width)
end
